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
            
            NSString* idString = [client currentUser].id;
            NSDictionary *note = @{@"recipients": @[idString],
                                   @"message": @"Message",
                                   @"payload": @"Payload",
                                   @"osCustomData":@"{}",
                                   @"type":@"raw"};
            
            [Buddy POST:@"/notifications" parameters:note class:[NSDictionary class] callback:^(id object, NSError *error){
                [error shouldBeNil];
                fin = YES;
            }];
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
    });
});

SPEC_END
