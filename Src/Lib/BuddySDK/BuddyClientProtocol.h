//
//  BuddyClientProtocol.h
//  BuddySDK
//
//  Created by Nick Ambrose on 7/30/14.
//
//

#ifndef BuddySDK_BuddyClientProtocol_h
#define BuddySDK_BuddyClientProtocol_h

#import "BuddyCallbacks.h"

@class BPCoordinate;
@class BPNotification;
@class BPModelUser;


/**
 * Enum specifying the current authentication level.
 */
typedef NS_ENUM(NSInteger, BPReachabilityLevel) {
    /** No network reachability */
    BPReachabilityNone     = 0,
    /** Reachable via carrier */
    BPReachabilityCarrier = 1,
    /** Reachability not known */
    BPReachabilityWiFi = 2,
};

@protocol BPClientDelegate <NSObject>

@optional
- (void)userChangedTo:(BPModelUser *)newUser from:(BPModelUser *)oldUser;

- (void)connectivityChanged:(BPReachabilityLevel)level;

- (void)apiErrorOccurred:(NSError *)error;

- (void)authorizationNeedsUserLogin;

@end

@protocol BuddyClientProtocol <NSObject>

@property (readonly, nonatomic, copy) NSString *appID;
@property (readonly, nonatomic, copy) NSString *appKey;

@property (nonatomic, strong) BPCoordinate *lastLocation;

@property (nonatomic, readonly, assign) BPReachabilityLevel reachabilityLevel;

@property (nonatomic, strong) BPModelUser *currentUser;

@property (nonatomic,weak) id<BPClientDelegate> delegate;


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

- (void)logoutUser:(BuddyCompletionCallback)callback;

- (void)GET:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
- (void)POST:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
- (void)PATCH:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
- (void)PUT:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;
- (void)DELETE:(NSString *)servicePath parameters:(NSDictionary *)parameters class:(Class)clazz callback:(RESTCallback)callback;

- (void)sendPushNotification:(BPNotification *)notification callback:(BuddyCompletionCallback)callback;

- (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value timeout:(NSInteger)seconds callback:(BuddyMetricCallback)callback;
- (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value callback:(BuddyCompletionCallback)callback;
- (void)recordMetric:(NSString *)key andValue:(NSDictionary *)value timeout:(NSInteger)seconds timestamp:(NSDate*)timestamp callback:(BuddyMetricCallback)callback;

@end

#endif
