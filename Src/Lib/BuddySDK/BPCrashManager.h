//
//  BPCrashManager.h
//  BuddySDK
//
//  Created by Erik.Kerber on 3/11/14.
//
//

#import <Foundation/Foundation.h>
#import "BPRestProvider.h"
#import "Buddy.h"

@interface BPCrashManager : NSObject

- (instancetype)initWithRestProvider:(id<BPRestProvider>)restProvider;
- (void)startReporting:(NSString *)appId;

@end
