//
//  CryptoTools.h
//  BuddySDK
//
//  Created by Nick Ambrose on 8/6/14.
//
//

#import <Foundation/Foundation.h>

@interface CryptoTools : NSObject

+(NSString*) hmac256ForKey:(NSString*)key andData:(NSString *)data;

@end
