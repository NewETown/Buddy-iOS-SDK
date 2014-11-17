//
//  CryptoTools.m
//  BuddySDK
//
//  Created by Nick Ambrose on 8/6/14.
//
//
#import <CommonCrypto/CommonHMAC.h>

#import "NSData+BPConversion.h"
#import "CryptoTools.h"

@implementation CryptoTools

+(NSString*) hmac256ForKey:(NSString*)key andData:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *hashed = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return [hashed hexadecimalString];
    
}
@end
