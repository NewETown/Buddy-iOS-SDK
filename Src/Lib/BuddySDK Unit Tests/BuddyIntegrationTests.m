//
//  BuddyIntegrationTests.m
//  BuddySDK
//
//  Created by Erik Kerber on 11/25/13.
//
//

#import "Buddy.h"
#import <Kiwi/Kiwi.h>
#import "BPAppSettings+Private.h"
#import "BuddyIntegrationHelper.h"

#import "BPUser.h"

#ifdef kKW_DEFAULT_PROBE_TIMEOUT
#undef kKW_DEFAULT_PROBE_TIMEOUT
#endif
#define kKW_DEFAULT_PROBE_TIMEOUT 4.0


SPEC_BEGIN(BuddyIntegrationSpec)

describe(@"Buddy", ^{
    context(@"A clean boot of your app", ^{
        
        __block BOOL fin = NO;
        __block NSString *userName = [BuddyIntegrationHelper getUUID];
        __block id<BuddyClientProtocol> client;
        
        beforeAll(^{
            
            [BPAppSettings resetSettings:nil];
            
            [Buddy init:APP_ID appKey:APP_KEY];
            
            client = [Buddy currentClient];
            
        });
        
        beforeEach(^{
            fin = NO;
        });
        
        afterAll(^{

        });
        
        it(@"Should allow you to create a user.", ^{
            __block NSDate *randomDate = [BuddyIntegrationHelper randomDate];
            
            NSString *email = [NSString stringWithFormat:@"user-%@@buddytest.com",[BuddyIntegrationHelper getUUID]];
            [Buddy createUser:userName
                     password:TEST_PASSWORD
                    firstName:@"Erik"
                     lastName:@"Kerber"
                        email:email
                  dateOfBirth:randomDate gender:@"male" tag:nil callback:^(id obj,NSError *error) {
                      fin = YES;
                      
                      BPUser *user = (BPUser*)obj;
                      
                      [[user should] beNonNil];
                      
                      [[user.userName should] equal:userName];
                      [[user.firstName should] equal:@"Erik"];
                      [[user.lastName should] equal:@"Kerber"];
                      [[user.dateOfBirth should] equal:randomDate];
                      [[user.gender should] equal: @"Male"];
                      
                  }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should allow you to login.", ^{
            __block BPUser *newUser;
            
            [Buddy loginUser:userName password:TEST_PASSWORD callback:^(id obj, NSError *error) {
                newUser = (BPUser*)obj;
                [[newUser.userName should] equal:userName];
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
    });
});

SPEC_END
