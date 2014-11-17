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
#import "BPFile.h"
#import "BPClient.h"
#import "CryptoTools.h"

typedef void (^AFFailureCallback)(AFHTTPRequestOperation *operation, NSError *error);
typedef void (^AFSuccessCallback)(AFHTTPRequestOperation *operation, id responseObject);

@interface BPServiceController()

@property (nonatomic, strong) BPAppSettings *appSettings;
@property (nonatomic, strong) NSString *sharedSecret; // Held outside of appSettings so we dont persist it to stable storage
@property (nonatomic, strong) AFJSONRequestSerializer *jsonRequestSerializer;
@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer *httpResponseSerializer;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSString *token;

-(void) makeRequest:(NSString*)verb servicePath:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback;
-(void) makeFileRequest:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback;
-(void) makeMultipartRequest:(NSString*)verb servicePath:(NSString *)servicePath parameters:(NSDictionary *)parameters data:(NSDictionary *)data callback:(REST_ServiceResponse)callback;

-(NSString*) makeStringToSign:(NSString*)verb path:(NSString*)path;
-(NSString*) generateSigForRequest:(NSString*)verb path:(NSString*)path;

-(void) setAuthHeader:(NSMutableURLRequest*)request verb:(NSString*)verb path:(NSString*)path;

@end

@implementation BPServiceController

- (instancetype)initWithAppSettings:(BPAppSettings *)appSettings andSecret:(NSString*)secret
{
    self = [super init];
    if(self)
    {
        _sharedSecret = secret;
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

-(NSString*) makeStringToSign:(NSString*)verb path:(NSString*)path
{
    NSString *verbUpper = [verb uppercaseString];
    
    NSString *fullPath = path;
    
    if(![path hasPrefix:@"/"])
    {
        fullPath = [NSString stringWithFormat:@"/%@",path];
    }
    
    return [NSString stringWithFormat:@"%@\n%@\n%@",verbUpper,self.appSettings.appID,fullPath];
}

-(NSString*) generateSigForRequest:(NSString*)verb path:(NSString*)path
{
    NSString *stringToSign = [self makeStringToSign:verb path:path];
    if(!stringToSign)
    {
        return nil;
    }
    return [CryptoTools hmac256ForKey:self.sharedSecret andData:stringToSign];
}

#pragma mark - Token Management
- (void)setupManagerWithNewSettings
{
    assert([self.appSettings.serviceUrl length] > 0);
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.appSettings.serviceUrl]];

    if(self.appSettings.token){
        NSLog(@"Setting token: %@", self.appSettings.token);
    }

    self.manager.responseSerializer = self.jsonResponseSerializer;
    self.manager.requestSerializer = self.jsonRequestSerializer;
}

-(void) setAuthHeader:(NSMutableURLRequest*)request verb:(NSString*)verb path:(NSString*)path
{
    if(self.appSettings && self.appSettings.token)
    {
        if(self.sharedSecret)
        {
            NSString *signature = [self generateSigForRequest:verb path:path];
            if(signature)
            {
                NSString *authString = [NSString stringWithFormat:@"Buddy %@ %@",self.appSettings.token,signature];
                [request setValue:authString forHTTPHeaderField:@"Authorization"];
            }
        }
        else
        {
            NSString *authString = [@"Buddy " stringByAppendingString:self.appSettings.token];
            [request setValue:authString forHTTPHeaderField:@"Authorization"];
        }
    }
}

#pragma mark REST Provider

-(void) makeRequest:(NSString*)verb servicePath:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    NSString *servicePathEncoded =servicePath;
    if( (! [[verb uppercaseString] isEqualToString:@"GET"]) &&
         (! [[verb uppercaseString] isEqualToString:@"DELETE"]) )
    {
        servicePathEncoded = [servicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *request = [self.jsonRequestSerializer requestWithMethod:verb URLString:[[NSURL URLWithString:servicePathEncoded relativeToURL:self.manager.baseURL] absoluteString] parameters:parameters error:nil];
    
    [self setAuthHeader:request verb:verb path:servicePath];
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:[self REST_handleSuccess:callback]
                                                                              failure:[self REST_handleFailure:callback]];
    
    [operation setResponseSerializer:self.jsonResponseSerializer];
    
    [self.manager.operationQueue addOperation:operation];
}


-(void) makeFileRequest:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:servicePath relativeToURL:self.manager.baseURL] absoluteString] parameters:parameters error:nil];
    
    [self setAuthHeader:request verb:@"GET" path:servicePath];
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:[self REST_handleSuccess :callback json:NO]
                                                                              failure:[self REST_handleFailure:callback]];
    [operation setResponseSerializer:self.httpResponseSerializer];
    
    [self.manager.operationQueue addOperation:operation];
    
}

-(void) makeMultipartRequest:(NSString*)verb servicePath:(NSString *)servicePath parameters:(NSDictionary *)parameters data:(NSDictionary *)data callback:(REST_ServiceResponse)callback
{
    void (^constructBody)(id <AFMultipartFormData> formData) =^(id<AFMultipartFormData> formData){
        for(NSString *name in [data allKeys]){
            BPFile *file = [data objectForKey:name];
            
            [formData appendPartWithFileData:file.fileData name:name fileName:name mimeType:file.contentType];
        }
    };
    
    NSString *servicePathEncoded =servicePath;
    if( (! [[verb uppercaseString] isEqualToString:@"GET"]) &&
       (! [[verb uppercaseString] isEqualToString:@"DELETE"]) )
    {
        servicePathEncoded = [servicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *request = [self.jsonRequestSerializer multipartFormRequestWithMethod:verb URLString:[[NSURL URLWithString:servicePathEncoded relativeToURL:self.manager.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:constructBody
                                                                                        error:nil];
    [self setAuthHeader:request verb:verb path:servicePath];
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:[self REST_handleSuccess:callback]
                                                                              failure:[self REST_handleFailure:callback]];
    
    [operation setResponseSerializer:self.jsonResponseSerializer];
    
    [self.manager.operationQueue addOperation:operation];
    
}

- (void)REST_GET_FILE:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    [self makeFileRequest:servicePath parameters:parameters callback:callback];
}

- (void)REST_GET:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    [self makeRequest:@"GET" servicePath:servicePath parameters:parameters callback:callback];
}

- (void)REST_POST:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    [self makeRequest:@"POST" servicePath:servicePath parameters:parameters callback:callback];
}

- (void)REST_PATCH:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    [self makeRequest:@"PATCH" servicePath:servicePath parameters:parameters callback:callback];
}

- (void)REST_PUT:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    [self makeRequest:@"PUT" servicePath:servicePath parameters:parameters callback:callback];
}

- (void)REST_DELETE:(NSString *)servicePath parameters:(NSDictionary *)parameters callback:(REST_ServiceResponse)callback
{
    [self makeRequest:@"DELETE" servicePath:servicePath parameters:parameters callback:callback];
}

- (void)REST_MULTIPART_POST:(NSString *)servicePath parameters:(NSDictionary *)parameters data:(NSDictionary *)data callback:(REST_ServiceResponse)callback
{
    [self makeMultipartRequest:@"POST" servicePath:servicePath parameters:parameters data:data callback:callback];
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
