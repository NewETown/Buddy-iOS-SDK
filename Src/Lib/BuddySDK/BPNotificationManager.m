//
//  BPNotificationManager.m
//  BuddySDK
//
//  Created by Erik.Kerber on 3/26/14.
//
//

#import "BPNotificationManager.h"
#import "BPNotification.h"
#import "BPRestProvider.h"

@interface BPNotificationManager()

@property (weak, nonatomic) id<BPRestProvider> client;

@end

@implementation BPNotificationManager

- (instancetype)initWithClient:(id<BPRestProvider>)client{
    self = [super init];
    if(self){
        _client = client;
    }
    return self;
}

- (void)acknowledgeNotificationRecieved:(NSString *)key
{
    NSString *resource = [NSString stringWithFormat:@"/notifications/received/%@", key];
    
    [self.client POST:resource parameters:nil class:[NSDictionary class] callback:^(id json, NSError *error) {
       // Anything?
    }];
}

- (void)sendPushNotification:(BPNotification *)notification callback:(BuddyCompletionCallback)callback
{
    NSString *url = @"notifications";
    
    NSString *pushType=nil;
    switch(notification.notificationType)
    {
        case BPNotificationType_None:
            // TODO: Construct an error here?
            callback(nil);
            return;
        case BPNotificationType_Alert:
            pushType = @"alert";
            break;
        case BPNotificationType_Raw:
            pushType = @"raw";
            break;
        case BPNotificationType_Badge:
            pushType = @"badge";
            break;
        case BPNotificationType_Custom:
            pushType=@"custom";
            break;
    }
    
    NSDictionary *parameters = @{
                                 @"type": pushType,
                                 @"message": BOXNIL(notification.message),
                                 @"payload": BOXNIL(notification.payload),
                                 @"counterValue": @(notification.counterValue),
                                 @"osCustomData": BOXNIL(notification.osCustomData),
                                 @"recipients": BOXNIL(notification.recipients)
                                 };
    
    [self.client POST:url parameters:parameters class:[NSDictionary class] callback:^(id json, NSError *error) {
        callback(error);
    }];
}

@end
