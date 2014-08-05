//
//  CheckinIntegrationTests.m
//  BuddySDK
//
//  Created by Erik Kerber on 12/2/13.
//
//

#import "Buddy.h"
#import "BuddyIntegrationHelper.h"
#import <Kiwi/Kiwi.h>

#ifdef kKW_DEFAULT_PROBE_TIMEOUT
#undef kKW_DEFAULT_PROBE_TIMEOUT
#endif
#define kKW_DEFAULT_PROBE_TIMEOUT 10.0

SPEC_BEGIN(NotificationsSpec)

describe(@"Notifications", ^{
    context(@"When an app has a valid device token", ^{
        __block BOOL fin = NO;

        __block id<BuddyClientProtocol> client;
        
        beforeAll(^{
            [BuddyIntegrationHelper bootstrapLogin:^{
                
                client = [Buddy currentClient];
                
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        beforeEach(^{
            fin = NO;
        });
        
        afterAll(^{
        });
        
        it(@"Should allow sending a notification", ^{
            
            BPNotification *note = [BPNotification new];
            NSString* idString = [client currentUser].id;
            note.recipients = @[idString];
            note.message = @"Message";
            note.payload = @"Payload";
            note.osCustomData = @"{}";
            note.notificationType = BPNotificationType_Raw;
            
            [Buddy sendPushNotification:note callback:^(NSError *error) {
                [[error should] beNil];
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
    });
});

SPEC_END
