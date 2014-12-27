//
//  BPAppSettings.m
//  BuddySDK
//
//  Created by Erik Kerber on 1/30/14.
//
//

#import "BPAppSettings.h"

@interface BPAppSettings()

@property (nonatomic, strong) NSString *initialURL;
@property (nonatomic, strong) NSString *keyString;

@end

@implementation BPAppSettings

@synthesize serviceUrl = _serviceUrl;
@synthesize deviceTag;
@synthesize deviceUniqueId;

- (instancetype)initWithAppId:(NSString *)appID andKey:(NSString *)appKey initialURL:(NSString *)initialURL
{
    self = [self initWithAppId:appID andKey:appKey initialURL:initialURL prefix:nil];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithAppId:(NSString *)appID andKey:(NSString *)appKey initialURL:(NSString *)initialURL prefix:(NSString *)prefix
{
    self = [super init];
    if (self) {
        _appID = appID;
        _appKey = appKey;
        _initialURL = initialURL;
        _keyString = [NSString stringWithFormat:@"%@BPUserSettings", prefix];

        if (_appID) {
            [self restoreSettings:prefix];
        }
        
        [self addObserver:self forKeyPath:@"appID" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"appKey" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"serviceUrl" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"deviceToken" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"deviceTokenExpires" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"userToken" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"userTokenExpires" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"userID" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"osVersion" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"appID"];
    [self removeObserver:self forKeyPath:@"appKey"];
    [self removeObserver:self forKeyPath:@"serviceUrl"];
    [self removeObserver:self forKeyPath:@"deviceToken"];
    [self removeObserver:self forKeyPath:@"deviceTokenExpires"];
    [self removeObserver:self forKeyPath:@"userToken"];
    [self removeObserver:self forKeyPath:@"userTokenExpires"];
    [self removeObserver:self forKeyPath:@"userID"];
    [self removeObserver:self forKeyPath:@"osVersion"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self saveSettings];
}

#pragma mark - Custom accessors

- (NSString *)serviceUrl
{
    return _serviceUrl ?: _initialURL;
}

- (NSString *)token
{
    return self.userToken ?: self.deviceToken ?: nil;
}

#pragma mark - BPAppSettings

- (void)clear
{
    self.deviceToken = nil;
    self.deviceTokenExpires = nil;
    self.lastUserID = nil;
    [self clearUser];
}

- (void)clearUser
{
    self.userToken = nil;
    self.userTokenExpires = nil;
    self.userID = nil;
}

- (void)saveSettings
{
    NSDictionary *settings = [[JAGPropertyConverter bp_converter] convertToDictionary:self];
    
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:self.keyString];
}

- (void)restoreSettings:(NSString *)prefix
{
    NSDictionary *restoredSettings = [[NSUserDefaults standardUserDefaults] objectForKey:self.keyString];
    
    NSLog(@"Restored settings!!");
    NSLog(@"%@", restoredSettings);
    
    if (!restoredSettings) {
        return;
    }
    
    [[JAGPropertyConverter bp_converter] setPropertiesOf:self fromDictionary:restoredSettings];
}

+ (void)resetSettings
{
    [self resetSettings:nil];
}

+ (void)resetSettings:(NSString *)prefix
{
    NSString *keyString = [NSString stringWithFormat:@"%@BPUserSettings", prefix];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:keyString];
}

@end
