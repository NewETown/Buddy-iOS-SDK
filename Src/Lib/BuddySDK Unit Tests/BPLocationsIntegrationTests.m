//
//  CheckinIntegrationTests.m
//  BuddySDK
//
//  Created by Erik Kerber on 12/2/13.
//
//

#import "Buddy.h"
#import "BuddyIntegrationHelper.h"
#import "BPLocation.h"
#import <Kiwi/Kiwi.h>

#ifdef kKW_DEFAULT_PROBE_TIMEOUT
#undef kKW_DEFAULT_PROBE_TIMEOUT
#endif
#define kKW_DEFAULT_PROBE_TIMEOUT 10.0

SPEC_BEGIN(BuddyLocationsSpec)

describe(@"BPLocationIntegrationSpec", ^{
    context(@"When a user is logged in", ^{
        
        __block BPLocation *tempLocation;
        __block BOOL fin = NO;

        beforeAll(^{
            
            [Buddy setLocationEnabled:YES];

            [BuddyIntegrationHelper bootstrapLogin:^{
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        beforeEach(^{
            fin = NO;
        });
        
        it(@"Should allow you create a location.", ^{
            
            tempLocation = [BPLocation new];
            tempLocation.name = @"House of Pain";
            tempLocation.description = @"Where the pain is brought";
            tempLocation.location = BPCoordinateMake(1.2, 3.4);
            tempLocation.category = @"So much pain";
            tempLocation.isPublic = YES;
            tempLocation.tag = @"Some Tag";
            
            [[Buddy locations] addLocation:tempLocation callback:^(NSError *error) {
                [[error should] beNil];
                [[tempLocation.id should] beNonNil];
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should allow updating a location", ^{
            tempLocation.name = @"New Name";
            [tempLocation save:^(NSError *error) {
                [[error should] beNil];
                [[tempLocation.name should] equal:@"New Name"];
                fin = YES;
            }];
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        
        it(@"Should allow you to search for a location.", ^{
            __block NSArray *locations;
            [[Buddy locations] searchLocation:^(id<BPLocationProperties,BPSearchProperties> locationProperties) {
                locationProperties.range = BPCoordinateRangeMake(1.2345, 3.4567, 100);
                locationProperties.limit = 9;
            } callback:^(NSArray *buddyObjects, NSError *error) {
                [[error should] beNil];
                locations = buddyObjects;
                [[locations should] beNonNil];
                [[theValue([locations count]) should] beGreaterThan:theValue(0)];

                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should allow deleting a location.", ^{
            [tempLocation destroy:^(NSError *error) {
                [[error should] beNil];
                fin = YES;
            }];
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
    });
});

SPEC_END
