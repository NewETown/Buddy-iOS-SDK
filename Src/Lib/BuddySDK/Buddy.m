/*
 * Copyright (C) 2013 Buddy Platform, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

#import "Buddy.h"
#import "Buddy+Private.h"
#import "BPClient.h"

@implementation Buddy

static NSMutableDictionary *clients;

static BPClient* currentClient;

+(id<BuddyClientProtocol>)currentClient{
    return currentClient;
}

+(BPClient*) currentClientObject
{
    return currentClient;
}

+ (BPModelUser *)user
{
    return [[self currentClient] currentUser];
}

+ (void) setUser:(BPModelUser *)user
{
    [[self currentClientObject] setCurrentUser:user];
}

+(void)initialize{
    clients = [[NSMutableDictionary alloc] init];
}

+ (void)setClientDelegate:(id<BPClientDelegate>)delegate
{
    currentClient.delegate = delegate;
}

+ (id<BuddyClientProtocol>)init:(NSString *)appID
            appKey:(NSString *)appKey
{
    return [self init:appID appKey:appKey autoRecordDeviceInfo:NO
               instanceName:nil];
}


+ (id<BuddyClientProtocol>)init:(NSString *)appID
                  appKey:(NSString *)appKey
    autoRecordDeviceInfo:(BOOL)autoRecordDeviceInfo
            instanceName:(NSString *)instanceName
{
    NSMutableDictionary *defaultOptions = [@{@"autoRecordDeviceInfo": @(autoRecordDeviceInfo)} mutableCopy];
    
    if(instanceName != nil)
    {
        [defaultOptions setObject:instanceName forKey:@"instanceName"];
    }
    return [self init:appID
                      appKey:appKey
                 withOptions:defaultOptions];
}

+ (id<BuddyClientProtocol>) init:(NSString *)appID
            appKey:(NSString *)appKey
            withOptions:(NSDictionary *)options
{
    NSString *clientKey = [NSString stringWithFormat:@"%@%@", appID, options[@"instanceName"]];
    
    
    if ([clients objectForKey:clientKey]) {
        currentClient = [clients objectForKey:clientKey];
        return currentClient;
    } else {
        BPClient* client = [[BPClient alloc] init];
        [client setupWithApp:appID appKey:appKey options:options delegate:nil];
        
        [clients setValue:client forKey:clientKey];
        currentClient = client;
        
        return client;
    }
}

#pragma mark User


+ (void)createUser:(NSString*) userName
          password:(NSString*) password
         firstName:(NSString*) firstName
          lastName:(NSString*) lastName
             email:(NSString*) email
       dateOfBirth:(NSDate*) dateOfBirth
            gender:(NSString*) gender
               tag:(NSString*) tag
          callback:(BuddyObjectCallback)callback
{
    [currentClient createUser:userName
                               password:password
                              firstName:firstName
                               lastName:lastName
                                  email:email
                            dateOfBirth:dateOfBirth
                                 gender:gender
                                    tag:tag
                               callback:callback];
}


+ (void)loginUser:(NSString *)username password:(NSString *)password callback:(BuddyObjectCallback)callback
{
    [currentClient loginUser:username password:password callback:callback];
}


+ (void)socialLogin:(NSString *)provider providerId:(NSString *)providerId token:(NSString *)token success:(BuddyObjectCallback) callback;
{
    [currentClient socialLogin:provider providerId:providerId token:token success:callback];
}

+ (void)logoutUser:(BuddyCompletionCallback)callback
{
    [currentClient logoutUser:callback];
}

+ (void)sendPushNotification:(BPNotification *)notification callback:(BuddyCompletionCallback)callback;
{
    [currentClient sendPushNotification:notification callback:callback];
}

+ (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value callback:(BuddyCompletionCallback)callback
{
    [currentClient recordMetric:key andValue:value callback:callback];
}

+ (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value timeout:(NSInteger)seconds callback:(BuddyMetricCallback)callback
{
    [currentClient recordMetric:key andValue:value timeout:seconds callback:callback];
}

+ (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value timeout:(NSInteger)seconds timestamp:(NSDate*)timestamp callback:(BuddyMetricCallback)callback
{
    [currentClient recordMetric:key andValue:value timeout:seconds timestamp:timestamp callback:callback];
}

#pragma mark - REST

+ (void)GET:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback
{
    [currentClient GET:servicePath parameters:parameters class:clazz callback:callback];
}

+ (void)POST:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback
{
    [currentClient POST:servicePath parameters:parameters class:clazz callback:callback];
}

+ (void)PATCH:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback
{
    [currentClient PATCH:servicePath parameters:parameters class:clazz callback:callback];
}

+ (void)PUT:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback
{
    [currentClient PUT:servicePath parameters:parameters class:clazz callback:callback];
}

+ (void)DELETE:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback
{
    [currentClient DELETE:servicePath parameters:parameters class:clazz callback:callback];
}


@end
