//
//  CheckinIntegrationTests.m
//  BuddySDK
//
//  Created by Erik Kerber on 12/2/13.
//
//

#import "Buddy.h"
#import "BuddyIntegrationHelper.h"
#import "NSDate+BPDateHelper.h"
#import <Kiwi/Kiwi.h>

#ifdef kKW_DEFAULT_PROBE_TIMEOUT
#undef kKW_DEFAULT_PROBE_TIMEOUT
#endif
#define kKW_DEFAULT_PROBE_TIMEOUT 10.0

SPEC_BEGIN(MetadataSpec)

describe(@"Metadata", ^{
    context(@"When a user is logged in", ^{
        
        __block BPCheckin *checkin1;
        __block BPCheckin *checkin2;
        __block BOOL fin = NO;
        
        beforeAll(^{
            
            DescribeCheckin d1 = ^(id<BPCheckinProperties> checkinProperties) {
                checkinProperties.comment = @"Test checkin";
                checkinProperties.description = @"Test checkin description";
                checkinProperties.location = BPCoordinateMake(1.2, 3.4);
            };

            DescribeCheckin d2 = ^(id<BPCheckinProperties> checkinProperties) {
                checkinProperties.comment = @"Second checkin";
                checkinProperties.description = @"Test checkin description";
                checkinProperties.location = BPCoordinateMake(1.2, 3.4);
            };
            
            [BuddyIntegrationHelper bootstrapLogin:^{
                
                [[Buddy checkins] checkin:d1
                 callback:^(id newBuddyObject, NSError *error) {
                    checkin1 = newBuddyObject;
                }];
                
                [[Buddy checkins] checkin:d2
                callback:^(id newBuddyObject, NSError *error) {
                     checkin2 = newBuddyObject;
                 }];
            }];
            
            [[expectFutureValue(checkin1) shouldEventually] beNonNil];
            [[expectFutureValue(checkin2) shouldEventually] beNonNil];
        });
        
        beforeEach(^{
            fin = NO;
        });
        
        afterAll(^{
            [Buddy logout:nil];
        });
        
        it(@"Should allow setting string metadata", ^{
            
            __block NSString *targetString = nil;
            __block NSString *targetString2 = nil;
            __block NSString *targetString3 = @"No Change";
            __block NSString *targetString4 = @"No Change";
            __block NSInteger targetInteger = 0;

            
            NSDictionary *kvp = @{@"Hakuna": @"Matata"};
            
            // App-level Metadata with Key Value Pairs
            [Buddy setMetadataValues:^(id<BPMetadataCollectionProperties> metadataProperties) {
                metadataProperties.values = kvp;
            } callback:^(NSError *error) {
                [Buddy getMetadataWithKey:@"Hakuna" permissions:BPPermissionsDefault callback:^(BPMetadataItem *metadata, NSError *error) {
                    [[metadata.value should] equal:@"Matata"];
                    targetString = metadata.value;
                    fin = YES;
                }];
            }];
            
            
            // App-level MetaData with Key/String
            [Buddy setMetadata:^(id<BPMetadataProperties> metadataProperties) {
                metadataProperties.key = @"Hey";
                metadataProperties.value = @"There";
                metadataProperties.permissions = BPPermissionsApp;
            } callback:^(NSError *error) {
                [[error should] beNil];
                [Buddy getMetadataWithKey:@"Hey" permissions:BPPermissionsApp callback:^(BPMetadataItem *metadata, NSError *error) {
                    targetString2 = metadata.value;
                }];
            }];

            // App-level Metadata - Check permissions (write as User, Get as App should fail)
            [Buddy setMetadata:^(id<BPMetadataProperties> metadataProperties) {
                metadataProperties.key = @"HeyHeyyy";
                metadataProperties.value = @"There";
                metadataProperties.permissions = BPPermissionsUser;
            } callback:^(NSError *error) {
                [[error should] beNil];
                [Buddy getMetadataWithKey:@"HeyHeyyy" permissions:BPPermissionsApp callback:^(BPMetadataItem *metadata, NSError *error) {
                    if(!error)
                    {
                        targetString3 = metadata.value;
                    }
                }];
                [Buddy getMetadataWithKey:@"HeyHeyyy" permissions:BPPermissionsUser callback:^(BPMetadataItem *metadata, NSError *error) {
                    if(!error)
                    {
                        targetString4 = metadata.value;
                    }
                }];
            }];
            
            // App-level Metadata - Set int and increment
            [Buddy setMetadata:^(id<BPMetadataProperties> metadataProperties) {
                metadataProperties.key = @"AppInc";
                metadataProperties.value = @(5);
            } callback:^(NSError *error) {
                [[error should] beNil];
                [Buddy incrementMetadata:@"AppInc" delta:2 callback:^(NSError *error) {
                    [[error should] beNil];
                    [Buddy getMetadataWithKey:@"AppInc" permissions:BPPermissionsUser callback:^(BPMetadataItem *metadata, NSError *error) {
                        [[error should] beNil];
                        targetInteger = [metadata.value integerValue];
                    }];
                }];
            }];
            
            [[expectFutureValue(targetString) shouldEventually] equal:@"Matata"];
            [[expectFutureValue(targetString2) shouldEventually] equal:@"There"];
            [[expectFutureValue(targetString3) shouldEventually] equal:@"No Change"];
            [[expectFutureValue(targetString4) shouldEventually] equal:@"There"];
            [[expectFutureValue(theValue(targetInteger)) shouldEventually] equal:theValue(7)];

            
        });
        
        
        it(@"Should be able to set nil  metadata", ^{
            __block id targetString1 = @"Stuff";
            
            __block BPCheckin *c1 = checkin1;

            [checkin1 setMetadata:^(id<BPMetadataProperties> metadataProperties) {
                metadataProperties.key = @"StringlyMetadata";
                metadataProperties.value = @"REMOVE";
            } callback:^(NSError *error) {
                [[error should] beNil];
                [c1 getMetadataWithKey:@"StringlyMetadata" permissions:BPPermissionsDefault callback:^(BPMetadataItem *metadata, NSError *error) {
                    targetString1 = metadata.value;
                }];
            }];
            
            [[expectFutureValue(targetString1) shouldEventually] equal:@"REMOVE"];
        });
        
        it(@"Should be able to set string based metadata", ^{
            __block id targetString1 = @"Stuff";
            __block id targetString2 = @"Stuff";
            
            
            __block BPCheckin *c1 = checkin1;
            __block BPCheckin *c2 = checkin2;
            
            [checkin1 setMetadata:^(id<BPMetadataProperties> metadataProperties) {
                metadataProperties.key = @"StringlyMetadata";
                metadataProperties.value = @"Test String";
            } callback:^(NSError *error) {
                [[error should] beNil];
                [c1 getMetadataWithKey:@"StringlyMetadata" permissions:BPPermissionsDefault callback:^(BPMetadataItem *metadata, NSError *error) {
                    targetString1 = metadata.value;
                }];
                [c2 getMetadataWithKey:@"StringlyMetadata" permissions:BPPermissionsDefault callback:^(BPMetadataItem *metadata, NSError *error) {
                    targetString2 = metadata.value;
                }];
            }];
            
            [[expectFutureValue(targetString1) shouldEventually] equal:@"Test String"];
            [[expectFutureValue(targetString2) shouldNotEventually] equal:@"Test String"];
        });
        
        it(@"Should be able to set integer based metadata", ^{
            __block NSInteger testInteger = 42;
            __block NSInteger targetInteger = -1;
            
            __block BPCheckin *c = checkin1;
            [checkin1 setMetadata:^(id<BPMetadataProperties> metadataProperties) {
                metadataProperties.key = @"IntlyMetadata";
                metadataProperties.value = @(testInteger);
            } callback:^(NSError *error) {
                [[error should] beNil];
                [c getMetadataWithKey:@"IntlyMetadata" permissions:BPPermissionsDefault callback:^(BPMetadataItem *metadata, NSError *error) {
                    targetInteger = [metadata.value integerValue];
                }];
            }];
            
            [[expectFutureValue(theValue(targetInteger)) shouldEventually] equal:theValue(testInteger)];
        });
        
        it(@"Should be increment metadata", ^{
            __block NSInteger testInteger = 42;
            NSInteger delta = 11;
            __block NSInteger targetInteger = -1;
            
            __weak BPCheckin *c = checkin1;
            [checkin1 setMetadata:^(id<BPMetadataProperties> metadataProperties) {
                metadataProperties.key = @"IncrementingMetadata";
                metadataProperties.value = @(testInteger);
            } callback:^(NSError *error) {
                [[error should] beNil];
                
                [c incrementMetadata:@"IncrementingMetadata" delta:delta callback:^(NSError *error) {
                    [[error should] beNil];
                    [c getMetadataWithKey:@"IncrementingMetadata" permissions:BPPermissionsDefault callback:^(BPMetadataItem *metadata, NSError *error) {
                        targetInteger = [metadata.value integerValue];
                    }];
                }];
            }];
            
            [[expectFutureValue(theValue(targetInteger)) shouldEventually] equal:theValue(testInteger + delta)];
        });
        
        it(@"Should be able to search metadata", ^{
            __block BOOL fin = NO;
            __weak BPCheckin *c = checkin1;
            
            // Make sure start and end bracked the server timestamp (they may not be completely in sync)
            NSDate *start = [[NSDate date] dateByAddingTimeInterval:-10];
            
            [checkin1 setMetadata:^(id<BPMetadataProperties> metadataProperties) {
                metadataProperties.key = @"MYPREFIXHello";
                metadataProperties.value = @(4);
            } callback:^(NSError *error) {
                [[error should] beNil];
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
            fin = NO;

            [c searchMetadata:^(id<BPMetadataProperties,BPSearchProperties> metadataSearchProperties) {
                metadataSearchProperties.keyPrefix = @"MYPREFIX";
            } callback:^(id newBuddyObject, NSError *error) {
                [[theValue([newBuddyObject count]) should] beGreaterThan:theValue(0)];
                for(BPMetadataItem *i in newBuddyObject) {
                    [[i.key should] startWithString:@"MYPREFIX"];
                }
                fin = YES;
            }];
            
            // Make sure start and end bracked the server timestamp (they may not be completely in sync)
            __block NSDate *end =[[NSDate date] dateByAddingTimeInterval:10];
            
            [c searchMetadata:^(id<BPMetadataProperties,BPSearchProperties> metadataSearchProperties) {
                //metadataSearchProperties.created = BPDateRangeMake([NSDate dateWithMinutesBeforeNow:5], [NSDate dateWithMinutesFromNow:5]);
            } callback:^(id newBuddyObject, NSError *error) {
                NSLog(@"METAMETA From: %@ To: %@",start,end);
                [[theValue([newBuddyObject count]) should] beGreaterThan:theValue(0)];
                for(BPMetadataItem *i in newBuddyObject) {
                    NSLog(@"%@", i.created);
                    
                    //[[i.created should] startWithString:@"MYPREFIX"];
                }
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should be able to delete metadata", ^{
            __block BPCheckin *c = checkin1;
            __block BOOL fin = NO;
            
            [c getMetadataWithKey:@"StringlyMetadata" permissions:BPPermissionsDefault callback:^(id newBuddyObject, NSError *error) {
                [[newBuddyObject shouldNot] beNil];
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
            fin = NO;
            
            [checkin1 deleteMetadataWithKey:@"StringlyMetadata" permissions:BPPermissionsDefault callback:^(NSError *error) {
                [c getMetadataWithKey:@"StringlyMetadata" permissions:BPPermissionsDefault callback:^(id newBuddyObject, NSError *error) {
                    [[newBuddyObject should] beNil];
                    fin = YES;
                }];
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should be able to set multi-valued metadata", ^{
            __block id targetString1 = @"Stuff";
            __block id targetString2 = @"Stuff";
            
            NSDictionary *keysValues = @{@"foo": @"bar"};
            
            __block BPCheckin *c1 = checkin1;
            __block BPCheckin *c2 = checkin2;
            
            
            [checkin1 setMetadataValues:^(id<BPMetadataCollectionProperties> metadataProperties) {
                metadataProperties.values = keysValues;
            } callback:^(NSError *error) {
                [[error should] beNil];
                [c1 getMetadataWithKey:@"foo" permissions:BPPermissionsDefault callback:^(BPMetadataItem *metadata, NSError *error) {
                    if(error==nil)
                    {
                        targetString1 = metadata.value;
                    }
                    else
                    {
                        targetString1=nil;
                    }
                }];
                [c2 getMetadataWithKey:@"foo" permissions:BPPermissionsDefault callback:^(BPMetadataItem *metadata, NSError *error) {
                    if(error==nil)
                    {
                        targetString2 = metadata.value;
                    }
                    else
                    {
                        targetString2 = nil;
                    }
                }];
            }];
            
            [[expectFutureValue(targetString1) shouldEventually] equal:@"bar"];
            [[expectFutureValue(targetString2) shouldNotEventually] equal:@"bar"];
        });
        
        it(@"Should allow setting a tag on an object", ^{
            NSString *myTag = @"Hello there!";
            checkin1.tag = myTag;
            
            [checkin1 save:^(NSError *error) {
                [[error should] beNil];
                [[Buddy checkins] getCheckin:checkin1.id callback:^(BPCheckin *newCheckin, NSError *error) {
                    [[newCheckin.tag should] equal:myTag];
                    fin = YES;
                }];
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
    });
});

SPEC_END
