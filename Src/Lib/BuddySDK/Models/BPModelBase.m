//
//  BPModelBase.m
//  BuddySDK
//
//  Created by Nick Ambrose on 7/16/14.
//
//

#import "BPModelBase.h"

@implementation BPModelBase

+(NSArray*) convertArrayOfDict:(NSArray*)dictArr toType:(Class)clazz
{
    NSArray *results = [dictArr bp_map:^id(id object)
    {
        id obj = [[clazz alloc] init];
        [[JAGPropertyConverter bp_converter] setPropertiesOf:obj fromDictionary:object];
        return obj;
    }];
    return results;
}

+ (id)convertValue:(NSString *)value forKey:(NSString *)key
{
    return nil;
}

+ (NSDictionary *)mapForProperty:(NSString *)key
{
    return [self enumMap][key];
}

+ (NSDictionary *)enumMap
{
    return @{NSStringFromSelector(@selector(readPermissions)) : @{
                     @(BPPermissionsApp) : @"App",
                     @(BPPermissionsUser) : @"User",
                     },
             NSStringFromSelector(@selector(writePermissions)) : @{
                     @(BPPermissionsApp) : @"App",
                     @(BPPermissionsUser) : @"User",
                     }};
}

@end
