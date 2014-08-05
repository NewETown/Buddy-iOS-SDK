//
//  Buddy+Private.h
//  BuddySDK
//
//  Created by Nick Ambrose on 7/30/14.
//
//

#ifndef BuddySDK_Buddy_Private_h
#define BuddySDK_Buddy_Private_h

#import "Buddy.h"

@class BPClient;

@interface Buddy(Private)

+(BPClient*) currentClientObject;

@end

#endif
