//
//  BuddyIntegrationHelper.h
//  BuddySDK
//
//  Created by Erik Kerber on 12/29/13.
//
//

#import <Foundation/Foundation.h>

@interface BuddyIntegrationHelper : NSObject

+ (void) bootstrapInit;

+ (void) bootstrapLogin:(void(^)())callback;

+ (NSDate *)randomDate;

+ (NSString *)randomString:(int)len;

+(NSString*) getUUID;
@end
