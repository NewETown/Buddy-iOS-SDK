//
//  Buddy.h
//  BuddySDK
//
//  Created by Erik Kerber on 11/15/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BuddyDevice.h"
#import "BPCoordinate.h"
#import "BPDateRange.h"

#import "BuddyClientProtocol.h"

#import "BPMetricCompletionHandler.h"
#import "BPSize.h"

// Models
#import "BPUser.h"
#import "BPCheckin.h"
#import "BPPageResults.h"
#import "BPPicture.h"
#import "BPUserList.h"

#import "BPFile.h"

@interface Buddy : NSObject

/* The currently logged in user. Will be nil if no login has occurred.
 *
 */
+ (BPUser*)user;
+ (void) setUser:(BPUser*)user;

+ (id<BuddyClientProtocol>) currentClient;

+ (void) setClientDelegate:(id<BPClientDelegate>)delegate;

/**
 *
 * Initialize the Buddy SDK with your App ID and App Key.
 *
 * @param appID  Your application ID.
 *
 * @param appKey Your application key.
 *
 */
+ (id<BuddyClientProtocol>)init:(NSString *)appID
            appKey:(NSString *)appKey;

+ (id<BuddyClientProtocol>) init:(NSString *)appID
                          appKey:(NSString *)appKey
                     withOptions:(NSDictionary *)options;

/**
 *
 * Create a new Buddy User.
 *
 *
 */
+ (void)createUser:(NSString*) userName
          password:(NSString*) password
         firstName:(NSString*) firstName
          lastName:(NSString*) lastName
             email:(NSString*) email
       dateOfBirth:(NSDate*) dateOfBirth
            gender:(NSString*) gender
               tag:(NSString*) tag
          callback:(BuddyObjectCallback)callback;

/**
 *
 * Login a user using the provided username and password.
 *
 * @param username  The username of the user.
 *
 * @param password  The user's password.
 *
 */
+ (void)loginUser:(NSString *)username password:(NSString *)password callback:(BuddyObjectCallback)callback;

/**
 *
 * Login using a social provider such as Facebook or Twitter.
 *
 */
+ (void)socialLogin:(NSString *)provider providerId:(NSString *)providerId token:(NSString *)token success:(BuddyObjectCallback) callback;

/**
 *
 * Logout the current user.
 *
 */
+ (void)logoutUser:(BuddyCompletionCallback)callback;


+ (void)recordNotificationReceived:(UIApplication *)application withDictionary:(NSDictionary *)userInfo;
+ (void)recordNotificationReceived:(UIApplication *)application withNotification:(UILocalNotification *)notification;



/** 
 * Records a metric.
 *
 * Signals completion via the BuddyCompletion callback.
 *
 * @param key       The name of the metric.
 *
 * @param value     The value of the metric.
 *
 * @param callback  A callback that is called once the server has processed the request.
 *
 */
+ (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value callback:(BuddyCompletionCallback)callback;

/** 
 * Records a timed metric.
 * @param key     The name of the metric.
 *
 * @param value   The value of the metric.
 *
 * @param timeout The time after which the metric automatically expires (in seconds).
 *
 * @param callback A callback that returns the ID of the metric which allows the metric to be signaled as finished
                 via "finishMetric."
 *
 */
+ (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value timeout:(NSInteger)seconds callback:(BuddyMetricCallback)callback;

/**
 * Records a timed metric.
 * @param key       The name of the metric.
 *
 * @param value     The value of the metric.
 *
 * @param timeout   The time after which the metric automatically expires (in seconds). If this value is set to zero, the parameter is not sent to the server
 *
 * @param timestamp The time at which the metric occurred
 *
 * @param callback  A callback that returns the ID of the metric which allows the metric to be signaled as finished
 via "finishMetric."
 *
 */
+ (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value timeout:(NSInteger)seconds timestamp:(NSDate*)timestamp callback:(BuddyMetricCallback)callback;

/**
 * REST calls
 */
+ (void)GET:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
+ (void)POST:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
+ (void)PATCH:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
+ (void)PUT:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
+ (void)DELETE:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;

@end
