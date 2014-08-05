//
//  BPServiceController.m
//  BuddySDK
//
//  Created by Erik Kerber on 11/15/13.
//
//

#import "BPServiceController.h"
#import "BPAFNetworking.h"
#import "BuddyDevice.h"
#import "NSError+BuddyError.h"
#import "BuddyFile.h"
#import "BPClient.h"

typedef void (^AFFailureCallback)(AFHTTPRequestOperation *operation, NSError *error);
typedef void (^AFSuccessCallback)(AFHTTPRequestOperation *operation, id responseObject);


@interface BPServiceController()

@property (nonatomic, strong) BPAppSettings *appSettings;

@property (nonatomic, strong) AFJSONRequestSerializer *jsonRequestSerializer;
@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer *httpResponseSerializer;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSString *token;

@end

@implementation BPServiceController

- (instancetype)initWithAppSettings:(BPAppSettings *)appSettings
{
    self = [super init];
    if(self)
    {
        _appSettings = appSettings;
        _jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpResponseSerializer = [AFHTTPResponseSerializer serializer];
        
        [_jsonRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_jsonRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_httpRequestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];

        [self addObserver:self forKeyPath:@"appSettings.userToken" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"appSettings.deviceToken" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"appSettings.serviceUrl" options:NSKeyValueObservingOptionNew context:nil];
        
        [self setupManagerWithNewSettings];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"appSettings.userToken"];
    [self removeObserver:self forKeyPath:@"appSettings.deviceToken"];
    [self removeObserver:self forKeyPath:@"appSettings.serviceUrl"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setupManagerWithNewSettings];
}

#pragma mark - Token Management
- (void)setupManagerWithNewSettings
{
    assert([self.appSettings.serviceUrl length] > 0);
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.appSettings.serviceUrl]];

    if(self.appSettings.token){
        NSLog(@"Setting token: %@", self.appSettings.token);
        // Tell our serializer our new Authorization string.
        NSString *authString = [@"Buddy " stringByAppendingString:self.appSettings.token];
        [self.jsonRequestSerializer setValue:authString forHTTPHeaderField:@"Authorization"];
        [self.httpRequestSerializer setValue:authString forHTTPHeaderField:@"Authorization"];
    }

    self.manager.responseSerializer = self.jsonResponseSerializer;
    self.manager.requestSerializer = self.jsonRequestSerializer;
}


#pragma mark REST Provider

- (void)REST_GET_FILE:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    self.manager.requestSerializer = self.httpRequestSerializer;
    self.manager.responseSerializer = self.httpResponseSerializer;
    
    [self.manager GET:servicePath
           parameters:parameters
              success:[self REST_handleSuccess:callback json:NO]
              failure:[self REST_handleFailure:callback]];
    
    self.manager.responseSerializer = self.jsonResponseSerializer;
    self.manager.requestSerializer = self.jsonRequestSerializer;
}

- (void)REST_GET:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    
    [self.manager GET:servicePath
           parameters:parameters
              success:[self REST_handleSuccess:callback]
              failure:[self REST_handleFailure:callback]];
    
}

- (void)REST_POST:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    NSString *servicePathEncoded =[servicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.manager POST:servicePathEncoded
            parameters:parameters
               success:[self REST_handleSuccess:callback]
               failure:[self REST_handleFailure:callback]];
}

- (void)REST_MULTIPART_POST:(NSString *)servicePath parameters:(NSDictionary *)parameters data:(NSDictionary *)data mimeType:(NSString *)mimeType callback:(REST_ServiceResponse)callback
{
    void (^constructBody)(id <AFMultipartFormData> formData) =^(id<AFMultipartFormData> formData){
        for(NSString *name in [data allKeys]){
            [formData appendPartWithFileData:data[name] name:name fileName:name mimeType:mimeType];
        }
    };
    
    NSString *servicePathEncoded =[servicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.manager POST:servicePathEncoded
            parameters:parameters
constructingBodyWithBlock:constructBody
               success:[self REST_handleSuccess:callback]
               failure:[self REST_handleFailure:callback]];
}


- (void)REST_PATCH:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    NSString *servicePathEncoded =[servicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.manager PATCH:servicePathEncoded
             parameters:parameters
                success:[self REST_handleSuccess:callback]
                failure:[self REST_handleFailure:callback]];
}

- (void)REST_PUT:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    NSString *servicePathEncoded =[servicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.manager PUT:servicePathEncoded
           parameters:parameters
              success:[self REST_handleSuccess:callback]
              failure:[self REST_handleFailure:callback]];
}

- (void)REST_DELETE:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    [self.manager DELETE:servicePath
              parameters:parameters
                 success:[self REST_handleSuccess:callback]
                 failure:[self REST_handleFailure:callback]];
}



- (void)REST_MULTIPART_POST:(NSString *)servicePath parameters:(NSDictionary *)parameters data:(NSDictionary *)data callback:(REST_ServiceResponse)callback
{
    
    void (^constructBody)(id <AFMultipartFormData> formData) =^(id<AFMultipartFormData> formData){
        for(NSString *name in [data allKeys]){
            BuddyFile *file = [data objectForKey:name];
            
            [formData appendPartWithFileData:file.fileData name:name fileName:name mimeType:file.contentType];
        }
    };
    
    NSString *servicePathEncoded =[servicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.manager POST:servicePathEncoded
            parameters:parameters
constructingBodyWithBlock:constructBody
               success:[self REST_handleSuccess:callback]
               failure:[self REST_handleFailure:callback]];
}

- (AFSuccessCallback) REST_handleSuccess:(REST_ServiceResponse)callback
{
    return [self REST_handleSuccess:callback json:YES];
}

- (AFSuccessCallback) REST_handleSuccess:(REST_ServiceResponse)callback json:(BOOL)json
{
    return ^(AFHTTPRequestOperation *operation, id responseObject){
        
        callback([operation response].statusCode, [[operation response] allHeaderFields],responseObject, nil);
    };
}

- (AFFailureCallback) REST_handleFailure:(REST_ServiceResponse)callback
{
    return ^(AFHTTPRequestOperation *operation, NSError *error){
        
        NSInteger statusCode = operation.response ? operation.response.statusCode : 0;
        callback(statusCode, [[operation response] allHeaderFields], operation.responseString, error);
    };
}


@end
