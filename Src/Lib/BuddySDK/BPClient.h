//
//  BPClient.h
//  BuddySDK
//
//  Created by Erik Kerber on 11/15/13.
//
//

#import <Foundation/Foundation.h>

#import "BuddyCallbacks.h"
#import "BPRestProvider.h"
#import "BPMetricCompletionHandler.h"
#import "BuddyClientProtocol.h"

@class BuddyDevice;
@class BPUser;

/**
 * Enum specifying the current authentication level.
 */
typedef NS_ENUM(NSInteger, BPAuthenticationLevel) {
    /** No authentication */
    BPAuthenticationLevelNone,
    /** App/Device level authentication */
    BPAuthenticationLevelDevice,
    /** User level authentication */
    BPAuthenticationLevelUser
};

@interface BPClient : NSObject <BPRestProvider,BuddyClientProtocol>

/// <summary>
/// Gets the application name for this client.
/// </summary>
@property (readonly, nonatomic, copy) NSString *appID;

/// <summary>
/// Gets the application password for this client.
/// </summary>
@property (readonly, nonatomic, copy) NSString *appKey;

/// <summary>
/// Gets the optional string that describes the version of the app you are building. This string is used when uploading
/// device information to Buddy or submitting crash reports. It will default to 1.0.
/// </summary>
@property (readonly, nonatomic, copy) NSString *appVersion;

/// <summary>
/// Gets an object that can be used to record device information about this client or upload crashes.
/// </summary>
@property (readonly, nonatomic, strong) BuddyDevice *device;

/**
  * Most recent BPCoordinate.
  */
@property (nonatomic, strong) BPCoordinate *lastLocation;

/**
 * Current reachability level.
 */
@property (nonatomic, readonly, assign) BPReachabilityLevel reachabilityLevel;

@property (nonatomic, strong) BPUser *currentUser;

@property (nonatomic,weak) id<BPClientDelegate> delegate;

-(void)setupWithApp:(NSString *)appID
                appKey:(NSString *)appKey
                options:(NSDictionary *)options
                delegate:(id<BPClientDelegate>)delegate;


- (void)createUser:(NSString*) userName
          password:(NSString*) password
         firstName:(NSString*) firstName
          lastName:(NSString*) lastName
             email:(NSString*) email
       dateOfBirth:(NSDate*) dateOfBirth
            gender:(NSString*) gender
               tag:(NSString*) tag
          callback:(BuddyObjectCallback)callback;

- (void)loginUser:(NSString *)username password:(NSString *)password callback:(BuddyObjectCallback)callback;
- (void)socialLogin:(NSString *)provider providerId:(NSString *)providerId token:(NSString *)token success:(BuddyObjectCallback) callback;

/**
 * Logs out the current user.
 */
- (void)logoutUser:(BuddyCompletionCallback)callback;

/**
 * REST Methods
 */
- (void)GET:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
- (void)POST:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
- (void)PATCH:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
- (void)PUT:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
- (void)DELETE:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
 
/** Records a metric.
 *
 * Signals completion via the BuddyCompletion callback.
 *
 * @param key     The name of the metric.
 *
 * @param value   The value of the metric.
 *
 */
- (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value callback:(BuddyCompletionCallback)callback;

/** Records a timed metric.
 * @param key     The name of the metric
 *
 * @param value   The value of the metric
 *
 * @param timeout The time after which the metric automatically expires (in seconds)
 *
 * @param callback A callback that returns the ID of the metric which allows the metric to be signaled as finished
 via "signalComplete"
 *
 */

- (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value timeout:(NSInteger)seconds callback:(BuddyMetricCallback)callback;

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
- (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value timeout:(NSInteger)seconds timestamp:(NSDate*)timestamp callback:(BuddyMetricCallback)callback;

- (void)registerPushTokenWithData:(NSData *)token callback:(BuddyObjectCallback) callback;
- (void)registerPushToken:(NSString *)token callback:(BuddyObjectCallback)callback;


@end
