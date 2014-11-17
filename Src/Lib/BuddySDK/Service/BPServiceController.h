//
//  BPServiceController.h
//  BuddySDK
//
//  Created by Erik Kerber on 11/15/13.
//
//

#import <Foundation/Foundation.h>
#import "BPAppSettings.h"
#import "BPRestProvider.h"


typedef void (^REST_ServiceResponse)(NSInteger responseCode, NSDictionary* responseHeaders,id response, NSError *error);

@interface BPServiceController : NSObject

-(instancetype) init __attribute__((unavailable("Use initWithUrl:")));
+(instancetype) new __attribute__((unavailable("Use with initWithUrl:")));

- (instancetype)initWithAppSettings:(BPAppSettings *)appSettings andSecret:(NSString*)secret;
- (void)REST_GET:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback;
- (void)REST_POST:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback;

- (void)REST_GET_FILE:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback;

- (void)REST_MULTIPART_POST:(NSString *)servicePath parameters:(NSDictionary *)parameters data:(NSDictionary *)data callback:(REST_ServiceResponse)callback;
- (void)REST_PATCH:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback;
- (void)REST_PUT:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback;
- (void)REST_DELETE:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback;


@end
