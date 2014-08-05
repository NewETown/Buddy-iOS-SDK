//
//  BPNotificationManager.h
//  BuddySDK
//
//  Created by Erik.Kerber on 3/26/14.
//
//

#import "BuddyCallbacks.h"
#import "BPRestProvider.h"

@class BPNotification;

@interface BPNotificationManager : NSObject

- (instancetype)initWithClient:(id<BPRestProvider>)client;

- (void)sendPushNotification:(BPNotification *)notification callback:(BuddyCompletionCallback)callback;

@end
