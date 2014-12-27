//
//  BPCrashManager.m
//  BuddySDK
//
//  Created by Erik.Kerber on 3/11/14.
//
//

#import "BPCrashManager.h"
#import <CrashReporter/CrashReporter.h>
#include <sys/sysctl.h>

#ifndef CPU_TYPE_ARM64
#define CPU_TYPE_ARM64 (CPU_TYPE_ARM | CPU_ARCH_ABI64)
#endif

@interface BPCrashManager()

@property (weak, nonatomic) id<BPRestProvider> restProvider;
@property (strong, nonatomic) NSString *appId;

@end

@implementation BPCrashManager {
    BOOL _isSetup;
    BOOL _didCrashInLastSession;
    PLCrashReporter *_plCrashReporter;
    NSUncaughtExceptionHandler *_exceptionHandler;
}

- (instancetype)initWithRestProvider:(id<BPRestProvider>)restProvider
{
    self = [super init];
    if (self) {
        _restProvider = restProvider;
    }
    return self;
}

- (void)startReporting:(NSString *)appId
{
    self.appId = appId;
    [self startManager];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCrashReport)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}


/**
 *	 Main startup sequence initializing PLCrashReporter if it wasn't disabled
 */
- (void)startManager {
    
    [self registerObservers];
    
    if (!_isSetup) {
        static dispatch_once_t plcrPredicate;
        dispatch_once(&plcrPredicate, ^{
            /* Configure our reporter */
            
            PLCrashReporterSignalHandlerType signalHandlerType = PLCrashReporterSignalHandlerTypeBSD;

            PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType: signalHandlerType
                                                                               symbolicationStrategy: PLCrashReporterSymbolicationStrategyAll];
            _plCrashReporter = [[PLCrashReporter alloc] initWithConfiguration: config];
            
            // Check if we previously crashed
            if ([_plCrashReporter hasPendingCrashReport]) {
                _didCrashInLastSession = YES;
                [self handleCrashReport];
            }
            
            // The actual signal and mach handlers are only registered when invoking `enableCrashReporterAndReturnError`
            // So it is safe enough to only disable the following part when a debugger is attached no matter which
            // signal handler type is set
            // We only check for this if we are not in the App Store environment
            
            BOOL debuggerIsAttached = NO;
            if ([self isDebuggerAttached]) {
                debuggerIsAttached = YES;
                NSLog(@"WARNING: Detecting crashes is NOT enabled due to running the app with a debugger attached.");
            }
            
            
            if (!debuggerIsAttached) {
                NSUncaughtExceptionHandler *initialHandler = NSGetUncaughtExceptionHandler();
                
                // PLCrashReporter may only be initialized once. So make sure the developer
                // can't break this
                NSError *error = NULL;
                
                // Enable the Crash Reporter
                if (![_plCrashReporter enableCrashReporterAndReturnError: &error])
                    NSLog(@"WARNING: Could not enable crash reporter: %@", [error localizedDescription]);
                
                // get the new current top level error handler, which should now be the one from PLCrashReporter
                NSUncaughtExceptionHandler *currentHandler = NSGetUncaughtExceptionHandler();
                
                // do we have a new top level error handler? then we were successful
                if (currentHandler && currentHandler != initialHandler) {
                    _exceptionHandler = currentHandler;
                    
                    NSLog(@"INFO: Exception handler successfully initialized.");
                } else {
                    // this should never happen, theoretically only if NSSetUncaugtExceptionHandler() has some internal issues
                    NSLog(@"ERROR: Exception handler could not be set. Make sure there is no other exception handler set up!");
                }
            }
            _isSetup = YES;
        });
    }    
}

#pragma mark - Crash Report Processing

- (void)triggerDelayedProcessing {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleCrashReport) object:nil];
    [self performSelector:@selector(handleCrashReport) withObject:nil afterDelay:0.5];
}

- (BOOL)reportIs64Bit:(PLCrashReport *)report
{
    BOOL lp64 = NO;
    /* Map to Apple-style code type, and mark whether architecture is LP64 (64-bit) */
    NSString *codeType __unused = nil;
    {
        /* Attempt to derive the code type from the binary images */
        for (PLCrashReportBinaryImageInfo *image in report.images) {
            /* Skip images with no specified type */
            if (image.codeType == nil)
                continue;
            
            /* Skip unknown encodings */
            if (image.codeType.typeEncoding != PLCrashReportProcessorTypeEncodingMach)
                continue;
            
            switch (image.codeType.type) {
                case CPU_TYPE_ARM:
                    codeType = @"ARM";
                    lp64 = false;
                    break;
                    
                case CPU_TYPE_ARM64:
                    codeType = @"ARM-64";
                    lp64 = true;
                    break;
                    
                case CPU_TYPE_X86:
                    codeType = @"X86";
                    lp64 = false;
                    break;
                    
                case CPU_TYPE_X86_64:
                    codeType = @"X86-64";
                    lp64 = true;
                    break;
                    
                case CPU_TYPE_POWERPC:
                    codeType = @"PPC";
                    lp64 = false;
                    break;
                    
                default:
                    // Do nothing, handled below.
                    break;
            }
            
            /* Stop immediately if code type was discovered */
            if (codeType != nil)
                break;
        }
        
        /* If we were unable to determine the code type, fall back on the legacy architecture value. */
        if (codeType == nil) {
            switch (report.systemInfo.architecture) {
                case PLCrashReportArchitectureARMv6:
                case PLCrashReportArchitectureARMv7:
                    codeType = @"ARM";
                    lp64 = false;
                    break;
                case PLCrashReportArchitectureX86_32:
                    codeType = @"X86";
                    lp64 = false;
                    break;
                case PLCrashReportArchitectureX86_64:
                    codeType = @"X86-64";
                    lp64 = true;
                    break;
                case PLCrashReportArchitecturePPC:
                    codeType = @"PPC";
                    lp64 = false;
                    break;
                default:
                    codeType = [NSString stringWithFormat: @"Unknown (%d)", report.systemInfo.architecture];
                    lp64 = true;
                    break;
            }
        }
    }
    return lp64;
}

/**
 * Format a stack frame for display in a thread backtrace.
 *
 * @param frameInfo The stack frame to format
 * @param frameIndex The frame's index
 * @param report The report from which this frame was acquired.
 * @param lp64 If YES, the report was generated by an LP64 system.
 *
 * @return Returns a formatted frame line.
 */
+ (NSString *)bw_formatStackFrame: (PLCrashReportStackFrameInfo *) frameInfo
                       frameIndex: (NSUInteger) frameIndex
                           report: (PLCrashReport *) report
                             lp64: (BOOL) lp64
{
    /* Base image address containing instrumention pointer, offset of the IP from that base
     * address, and the associated image name */
    uint64_t baseAddress __unused = 0x0;
    uint64_t pcOffset = 0x0;
    NSString *imageName = @"\?\?\?";
    NSString *symbolString = nil;
    
    PLCrashReportBinaryImageInfo *imageInfo = [report imageForAddress: frameInfo.instructionPointer];
    if (imageInfo != nil) {
        imageName = [imageInfo.imageName lastPathComponent];
        baseAddress = imageInfo.imageBaseAddress;
        pcOffset = frameInfo.instructionPointer - imageInfo.imageBaseAddress;
    }
    
    /* Make sure UTF8/16 characters are handled correctly */
    NSInteger offset = 0;
    NSInteger index = 0;
    for (index = 0; index < [imageName length]; index++) {
        NSRange range = [imageName rangeOfComposedCharacterSequenceAtIndex:index];
        if (range.length > 1) {
            offset += range.length - 1;
            index += range.length - 1;
        }
        if (index > 32) {
            imageName = [NSString stringWithFormat:@"%@... ", [imageName substringToIndex:index - 1]];
            index += 3;
            break;
        }
    }
    if (index-offset < 36) {
        imageName = [imageName stringByPaddingToLength:36+offset withString:@" " startingAtIndex:0];
    }
    
    /* If symbol info is available, the format used in Apple's reports is Sym + OffsetFromSym. Otherwise,
     * the format used is imageBaseAddress + offsetToIP */
    NSString *imagePath = [imageInfo.imageName stringByStandardizingPath];
    NSString *appBundleContentsPath = [[report.processInfo.processPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    
    if (frameInfo.symbolInfo != nil &&
        ![imagePath isEqual: report.processInfo.processPath] &&
        ![imagePath hasPrefix:appBundleContentsPath]) {
        NSString *symbolName = frameInfo.symbolInfo.symbolName;
        
        /* Apple strips the _ symbol prefix in their reports. Only OS X makes use of an
         * underscore symbol prefix by default. */
        if ([symbolName rangeOfString: @"_"].location == 0 && [symbolName length] > 1) {
            switch (report.systemInfo.operatingSystem) {
                case PLCrashReportOperatingSystemMacOSX:
                case PLCrashReportOperatingSystemiPhoneOS:
                case PLCrashReportOperatingSystemiPhoneSimulator:
                    symbolName = [symbolName substringFromIndex: 1];
                    break;
                    
                default:
                    NSLog(@"Symbol prefix rules are unknown for this OS!");
                    break;
            }
        }
        
        
        uint64_t symOffset = frameInfo.instructionPointer - frameInfo.symbolInfo.startAddress;
        symbolString = [NSString stringWithFormat: @"%@ + %" PRId64, symbolName, symOffset];
    } else {
        symbolString = [NSString stringWithFormat: @"%@ + %" PRId64, frameInfo.symbolInfo.symbolName, pcOffset];
        //symbolString = [NSString stringWithFormat: @"0x%" PRIx64 " + %" PRId64, baseAddress, pcOffset];
    }
    
    /* Note that width specifiers are ignored for %@, but work for C strings.
     * UTF-8 is not correctly handled with %s (it depends on the system encoding), but
     * UTF-16 is supported via %S, so we use it here */
    return [NSString stringWithFormat: @"%-4ld%-35S 0x%0*" PRIx64 " %@\n",
            (long) frameIndex,
            (const uint16_t *)[imageName cStringUsingEncoding: NSUTF16StringEncoding],
            lp64 ? 16 : 8, frameInfo.instructionPointer,
            symbolString];
}


- (void)sendCrashReports:(PLCrashReport *)crashReport onSuccess:(void (^)())onSuccess
{
    BOOL lp64 = [self reportIs64Bit:crashReport];

    
    // Exception
    NSString *message = nil;
    NSMutableString *crashedThreadString = [NSMutableString string];
    NSString *exceptionMethodName = [NSMutableString string];
    NSString *applicationName = [[crashReport.applicationInfo.applicationIdentifier componentsSeparatedByString:@"."] lastObject];
    if (crashReport.exceptionInfo) {
        // The easy way. We have exception info. Common for most crashes.
        
        message = crashReport.exceptionInfo.exceptionReason;
        
        for (NSUInteger frame_idx = 0; frame_idx < [crashReport.exceptionInfo.stackFrames count]; frame_idx++) {
            PLCrashReportStackFrameInfo *frameInfo = [crashReport.exceptionInfo.stackFrames objectAtIndex: frame_idx];
            
            [crashedThreadString appendString:[[self class] bw_formatStackFrame:frameInfo frameIndex:frame_idx report:crashReport lp64:lp64]];
        }
        
        for (NSUInteger frame_idx = 0; frame_idx < [crashReport.exceptionInfo.stackFrames count]; frame_idx++) {
            PLCrashReportStackFrameInfo *frameInfo = [crashReport.exceptionInfo.stackFrames objectAtIndex: frame_idx];
            
            PLCrashReportBinaryImageInfo *imageInfo = [crashReport imageForAddress:frameInfo.instructionPointer];
            if (imageInfo != nil) {
                if ([applicationName isEqualToString:[imageInfo.imageName lastPathComponent]]) {
                    // We work our way from the bottom of the stack. Report the first application frame we get to.
                    exceptionMethodName = frameInfo.symbolInfo.symbolName;
                    break;
                }
            }
        }
    } else {
        // Crap. There was something lower level, like overreleasing an object. Try to build the crash info from the thread list.
        
        PLCrashReportThreadInfo *crashed_thread = nil;
        for (PLCrashReportThreadInfo *thread in crashReport.threads) {
            if (thread.crashed) {
                crashed_thread = thread;
                for (NSUInteger frame_idx = 0; frame_idx < [thread.stackFrames count]; frame_idx++) {
                    PLCrashReportStackFrameInfo *frameInfo = [thread.stackFrames objectAtIndex: frame_idx];
                    [crashedThreadString appendString:[[self class] bw_formatStackFrame:frameInfo frameIndex:frame_idx report:crashReport lp64:lp64]];
                }
                break;
            }
        }

        
        for (NSUInteger frame_idx = 0; frame_idx < [crashed_thread.stackFrames count]; frame_idx++) {
            PLCrashReportStackFrameInfo *frameInfo = [crashed_thread.stackFrames objectAtIndex: frame_idx];
            
            PLCrashReportBinaryImageInfo *imageInfo = [crashReport imageForAddress:frameInfo.instructionPointer];
            if (imageInfo != nil) {
                if ([applicationName isEqualToString:[imageInfo.imageName lastPathComponent]]) {
                    // We work our way from the bottom of the stack. Report the first application frame we get to.
                    exceptionMethodName = frameInfo.symbolInfo.symbolName;
                    break;
                }
            }
        }
    }
    
    NSDictionary *parameters = @{@"message": BOXNIL(message),
                                 @"methodName": exceptionMethodName,
                                 @"stackTrace": crashedThreadString};
    
    [self.restProvider POST:@"devices/current/crashreports"  parameters:parameters class:[NSDictionary class] callback:^(id json, NSError *error) {
        if (!error) {
            onSuccess();
        }
    }];
}

- (void) handleCrashReport {
    NSError *error = NULL;
	
    if (!_plCrashReporter) return;
    
        
    // Try loading the crash report
    NSData *crashData = [[NSData alloc] initWithData:[_plCrashReporter loadPendingCrashReportDataAndReturnError: &error]];
    
    if (crashData == nil) {
        NSLog(@"ERROR: Could not load crash report: %@", error);
    } else {
        // get the startup timestamp from the crash report, and the file timestamp to calculate the timeinterval when the crash happened after startup
        PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];
        
        if (report == nil) {
            NSLog(@"WARNING: Could not parse crash report");
        } else {
            [self sendCrashReports:report onSuccess:^{
                [_plCrashReporter purgePendingCrashReport];
            }];
        }
    }
}


/**
 * Check if the debugger is attached
 *
 * Taken from https://github.com/plausiblelabs/plcrashreporter/blob/2dd862ce049e6f43feb355308dfc710f3af54c4d/Source/Crash%20Demo/main.m#L96
 *
 * @return `YES` if the debugger is attached to the current process, `NO` otherwise
 */
- (BOOL)isDebuggerAttached {
    static BOOL debuggerIsAttached = NO;
    
    static dispatch_once_t debuggerPredicate;
    dispatch_once(&debuggerPredicate, ^{
        struct kinfo_proc info;
        size_t info_size = sizeof(info);
        int name[4];
        
        name[0] = CTL_KERN;
        name[1] = KERN_PROC;
        name[2] = KERN_PROC_PID;
        name[3] = getpid();
        
        if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
            NSLog(@"ERROR: Checking for a running debugger via sysctl() failed: %s", strerror(errno));
            debuggerIsAttached = false;
        }
        
        if (!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0)
            debuggerIsAttached = true;
    });
    
    return debuggerIsAttached;
}

@end
