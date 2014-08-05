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

SPEC_BEGIN(MetricsSpec)

describe(@"Metrics", ^{
    context(@"When an app has a valid device token", ^{
        __block BOOL fin = NO;
        beforeAll(^{
            [Buddy init:APP_ID appKey:APP_KEY];
        });
        
        afterAll(^{
        });
        
        beforeEach(^{
            fin = NO;
        });
        
        it(@"Should allow recording untimed metrics", ^{
            NSDictionary *myVals = @{@"Foo": @"Bar"};
            
            [Buddy recordMetric:@"MetricKey2" andValue:myVals callback:^(NSError *error) {
                [[error should] beNil];
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should allow recording timed metrics", ^{
            NSDictionary *myVals = @{@"Foo": @"Bar"};

            [Buddy recordMetric:@"MetricKey" andValue:myVals timeout:10 callback:^(BPMetricCompletionHandler *completionHandler, NSError *error) {
                [[error should] beNil];
                [completionHandler finishMetric:^(NSInteger elapsedTimeInMs, NSError *error) {
                    [[theValue(elapsedTimeInMs) should] beGreaterThan:theValue(0)];
                    [[error should] beNil];
                    fin = YES;
                }];
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should allow recording timed metrics with timeout and timestamp", ^{
            NSDictionary *myVals = @{@"FooTimeoutAndTimestamp": @"Bar"};
            
            NSDate *metricTime = [BuddyIntegrationHelper randomDate];
            
            [Buddy recordMetric:@"MetricKeyTimeout And Timestamp" andValue:myVals timeout:10 timestamp:metricTime callback:^(BPMetricCompletionHandler *completionHandler, NSError *error) {
                [[error should] beNil];
                [completionHandler finishMetric:^(NSInteger elapsedTimeInMs, NSError *error) {
                    [[error should] beNil];
                    fin = YES;
                }];
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should allow recording timed metrics with just timestamp", ^{
            NSDictionary *myVals = @{@"FooTimestampOnly": @"Bar"};
            
            NSDate *metricTime = [BuddyIntegrationHelper randomDate];
            
            [Buddy recordMetric:@"MetricKeyTSOnly & Timestamp" andValue:myVals timeout:0 timestamp:metricTime callback:^(BPMetricCompletionHandler *completionHandler, NSError *error) {
                [[error should] beNil];
                [completionHandler finishMetric:^(NSInteger elapsedTimeInMs, NSError *error) {
                    [[error should] beNil];
                    fin = YES;
                }];
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
    });
});

SPEC_END
