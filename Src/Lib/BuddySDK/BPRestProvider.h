//
//  BPRestProvider.h
//  BuddySDK
//
//  Created by Erik Kerber on 12/29/13.
//
//

#import <Foundation/Foundation.h>
#import "BuddyCallbacks.h"

@protocol BPRestProvider <NSObject>

@required

- (void)GET:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class) clazz callback:(RESTCallback)callback;
- (void)POST:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class) clazz callback:(RESTCallback)callback;
- (void)PATCH:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class) clazz callback:(RESTCallback)callback;
- (void)PUT:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class) clazz callback:(RESTCallback)callback;
- (void)DELETE:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class) clazz callback:(RESTCallback)callback;

@end

