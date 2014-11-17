//
//  BPRest.m
//  BuddySDK
//
//  Created by Nick Ambrose on 7/16/14.
//
//

#import <CoreLocation/CoreLocation.h>

#import "Buddy.h"
#import "BuddyIntegrationHelper.h"

#import "BPCheckin.h"
#import "BPFile.h"
#import "BPPageResults.h"

#import <Kiwi/Kiwi.h>

#ifdef kKW_DEFAULT_PROBE_TIMEOUT
#undef kKW_DEFAULT_PROBE_TIMEOUT
#endif
#define kKW_DEFAULT_PROBE_TIMEOUT 10.0

SPEC_BEGIN(BPRESTIntegrationSpec)

describe(@"BPUser", ^{
    context(@"When a user is logged in", ^{
        
        __block BOOL fin = NO;
        beforeAll(^{
            [BuddyIntegrationHelper bootstrapLogin:^{
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        beforeEach(^{
            fin = NO;
        });

        it(@"Should allow creating a checkin with a dictionary", ^{
            
            __block BOOL fin = NO;
            NSDictionary *checkin = @{@"comment":@"my checkin with dict", @"description":@"it was a nice place",@"location":BPCoordinateMake(1.2, 3.4)};
            
            [Buddy POST:@"checkins" parameters:checkin class:[NSDictionary class] callback:^(id obj, NSError *error) {
                
                [[error should] beNil];
                if(error!=nil)
                {
                    return;
                }
                
                NSDictionary *checkinResult = (NSDictionary*)obj;
                if(checkinResult==nil)
                {
                    [[checkinResult should] beNonNil];
                    return;
                }
                
                NSString *returnedComment = [checkinResult objectForKey:@"comment"];
                [[returnedComment should] equal:@"my checkin with dict"];
                
                NSString *returnedDesc =[checkinResult objectForKey:@"description"];
                [[returnedDesc should] equal: @"it was a nice place"];
                
                fin = YES;
                
            }];
            [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
        });
        it(@"Should allow creating a checkin with a model", ^{
            
            __block BOOL fin = NO;
            NSDictionary *checkin = @{@"comment":@"my checkin with model", @"description":@"it was an even better place",@"location":BPCoordinateMake(11.2, 33.4)};
            
            [Buddy POST:@"checkins" parameters:checkin class:[BPCheckin class] callback:^(id obj, NSError *error) {
                
                [[error should] beNil];
                if(error!=nil)
                {
                    return;
                }
                
                BPCheckin *checkinResult = (BPCheckin*)obj;
                
                [[checkinResult.id should] beNonNil];
                
                [[checkinResult.created should] beNonNil];
                
                [[checkinResult.comment should] equal:@"my checkin with model"];
                
                [[checkinResult.description should] equal: @"it was an even better place"];
                
                fin = YES;
            }];
            [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
        });
        
        it(@"Should allow creating a checkin with CLLocation", ^{
            
            __block BOOL fin = NO;
            CLLocationDegrees lat = 22.4;
            CLLocationDegrees lng = 44.6;
            
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            
            NSDictionary *checkin = @{@"comment":@"my checkin with model", @"description":@"it was an even better place",@"location":loc};
            
            [Buddy POST:@"checkins" parameters:checkin class:[BPCheckin class] callback:^(id obj, NSError *error) {
                
                [[error should] beNil];
                if(error!=nil)
                {
                    return;
                }
                
                BPCheckin *checkinResult = (BPCheckin*)obj;
                [[checkinResult should] beNonNil];
                
                [[checkinResult.id should] beNonNil];
                
                [[checkinResult.created should] beNonNil];
                
                [[checkinResult.comment should] equal:@"my checkin with model"];
                
                [[checkinResult.description should] equal: @"it was an even better place"];
                
                [[theValue(checkinResult.location.lat) should] equal: 22.4 withDelta:FLT_EPSILON];
                [[theValue(checkinResult.location.lng) should] equal: 44.6 withDelta:FLT_EPSILON];
                fin = YES;
                
            }];
            [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
        });
    
        it(@"Should allow updating a checkin with a model", ^{
            
            __block BOOL fin = NO;
            NSDictionary *checkin = @{@"comment":@"my checkin with model", @"description":@"it was an even better place",@"location":BPCoordinateMake(11.2, 33.4)};
            
            [Buddy POST:@"checkins" parameters:checkin class:[BPCheckin class] callback:^(id obj, NSError *error) {
                
                [[error should] beNil];
                if(error!=nil)
                {
                    return;
                }
                
                BPCheckin *checkinResult = (BPCheckin*)obj;
                [[checkinResult should] beNonNil];
                
                [[checkinResult.id should] beNonNil];
                
                [[checkinResult.created should] beNonNil];
                
                [[checkinResult.comment should] equal:@"my checkin with model"];
                
                [[checkinResult.description should] equal: @"it was an even better place"];
                
                NSDictionary *checkinPatch = @{@"comment":@"my checkin with model patched"};
                
                [Buddy PATCH:[NSString stringWithFormat:@"/checkins/%@",checkinResult.id] parameters:checkinPatch class:[NSDictionary class] callback:^(id obj,  NSError *error) {
                    
                    [[error should] beNil];
                    if(error!=nil)
                    {
                        return;
                    }
                    
                    [Buddy GET:[NSString stringWithFormat:@"/checkins/%@",checkinResult.id] parameters:nil class: [BPCheckin class] callback:^(id getObj,  NSError *error)
                     {
                         BPCheckin *checkinResultPatched = (BPCheckin*)getObj;
                         [[checkinResult should] beNonNil];
                         
                         
                         [[checkinResultPatched.id should] equal:checkinResult.id];
                         
                         [[checkinResultPatched.created should] beNonNil];
                         
                         [[checkinResultPatched.comment should] equal:@"my checkin with model patched"];
                         
                         [[checkinResultPatched.description should] equal: @"it was an even better place"];
                         
                         fin = YES;
                     }];
                }];
                
            }];
            [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
        });
        
        it(@"Should allow deleting a checkin", ^{
        
        __block BOOL fin = NO;
        NSDictionary *checkin = @{@"comment":@"my checkin with model", @"description":@"it was an even better place",@"location":BPCoordinateMake(11.2, 33.4)};
        
        [Buddy POST:@"checkins" parameters:checkin class:[BPCheckin class] callback:^(id obj, NSError *error) {
            
            [[error should] beNil];
            if(error!=nil)
            {
                return;
            }
            
            BPCheckin *checkinResult = (BPCheckin*)obj;
            [[checkinResult should] beNonNil];
            
            [[checkinResult.id should] beNonNil];
            
            [[checkinResult.created should] beNonNil];
            
            [[checkinResult.comment should] equal:@"my checkin with model"];
            
            [[checkinResult.description should] equal: @"it was an even better place"];
            
            [Buddy DELETE:[NSString stringWithFormat:@"/checkins/%@",checkinResult.id] parameters:nil class:[BPCheckin class] callback:^(id obj,  NSError *error) {
                
                [[error should] beNil];
                if(error!=nil)
                {
                    return;
                }
                
                fin = YES;
                
            }];
            
        }];
        [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
    });
        
        it(@"Should allow searching checkins with a dictionary result", ^{
            
            __block BOOL fin = NO;
            NSDictionary *checkin = @{@"comment":@"my checkin to search", @"description":@"it was an even better place again",@"location":BPCoordinateMake(11.2, 33.4)};
            
            [Buddy POST:@"checkins" parameters:checkin class:[BPCheckin class] callback:^(id obj, NSError *error) {
                
                [[error should] beNil];
                if(error!=nil)
                {
                    return;
                }
                
                BPCheckin *checkinResult = (BPCheckin*)obj;
                [[checkinResult should] beNonNil];
                
                [[checkinResult.id should] beNonNil];
                
                [[checkinResult.created should] beNonNil];
                
                [[checkinResult.comment should] equal:@"my checkin to search"];
                
                [[checkinResult.description should] equal: @"it was an even better place again"];
                
                [Buddy POST:@"checkins" parameters:checkin class:[BPCheckin class] callback:^(id obj, NSError *error) {
                    
                    [[error should] beNil];
                    if(error!=nil)
                    {
                        return;
                    }
                    
                    BPCheckin *checkinResult = (BPCheckin*)obj;
                    [[checkinResult should] beNonNil];
                    
                    [[checkinResult.id should] beNonNil];
                    
                    [[checkinResult.created should] beNonNil];
                    
                    [[checkinResult.comment should] equal:@"my checkin to search"];
                    
                    [[checkinResult.description should] equal: @"it was an even better place again"];
                    
                    NSDictionary *searchParams = @{@"comment" : @"my checkin to search"};
                    
                    [Buddy GET:@"checkins" parameters:searchParams class: [NSDictionary class] callback:^(id getObj,  NSError *error)
                    {
                        [[error should] beNil];
                        if(error!=nil)
                        {
                            return;
                        }
                        
                        NSDictionary *searchResults = (NSDictionary*)getObj;
                        
                        NSString *currentToken = [searchResults objectForKey:@"currentToken"];
                        [[currentToken should] beNonNil];
                        
                        NSArray *pagedResults = [searchResults objectForKey:@"pageResults"];
                        [[pagedResults should] beNonNil];
                        
                        for(NSDictionary* searchedCheckin in pagedResults)
                        {
                            NSString *searchedID = [searchedCheckin objectForKey:@"id"];
                            [[searchedID should] beNonNil];
                            
                            NSString *searchedComment = [searchedCheckin objectForKey:@"comment"];
                            [[searchedComment should] equal:@"my checkin to search"];
                        }

                         fin = YES;
                     }];
                    
                }];
                
            }];
            [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
        });
        
        
        it(@"Should allow searching checkins with a model result", ^{
            
            __block BOOL fin = NO;
            NSDictionary *checkin = @{@"comment":@"my checkin to search", @"description":@"it was an even better place again",@"location":BPCoordinateMake(11.2, 33.4)};
            
            [Buddy POST:@"checkins" parameters:checkin class:[BPCheckin class] callback:^(id obj, NSError *error) {
                
                [[error should] beNil];
                if(error!=nil)
                {
                    return;
                }
                
                BPCheckin *checkinResult = (BPCheckin*)obj;
                [[checkinResult should] beNonNil];
                
                [[checkinResult.id should] beNonNil];
                
                [[checkinResult.created should] beNonNil];
                
                [[checkinResult.comment should] equal:@"my checkin to search"];
                
                [[checkinResult.description should] equal: @"it was an even better place again"];
                
                [Buddy POST:@"checkins" parameters:checkin class:[BPCheckin class] callback:^(id obj, NSError *error) {
                    
                    [[error should] beNil];
                    if(error!=nil)
                    {
                        return;
                    }
                    
                    BPCheckin *checkinResult = (BPCheckin*)obj;
                    [[checkinResult should] beNonNil];
                    
                    [[checkinResult.id should] beNonNil];
                    
                    [[checkinResult.created should] beNonNil];
                    
                    [[checkinResult.comment should] equal:@"my checkin to search"];
                    
                    [[checkinResult.description should] equal: @"it was an even better place again"];
                    
                    NSDictionary *searchParams = @{@"comment" : @"my checkin to search"};
                    
                    [Buddy GET:@"checkins" parameters:searchParams class: [BPSearch class] callback:^(id getObj,  NSError *error)
                     {
                         [[error should] beNil];
                         if(error!=nil)
                         {
                             return;
                         }
                         
                         BPSearch *searchResults = (BPSearch*)getObj;
                         
                         [[searchResults.currentToken should] beNonNil];
                         [[searchResults.pageResults should] beNonNil];
                         
                         NSArray *searchedCheckins = [searchResults convertPageResultsToType:[BPCheckin class]];
                   
                         [[searchedCheckins should] beNonNil];
                         
                         for(BPCheckin* searchedCheckin in searchedCheckins)
                         {
                             [[searchedCheckin.id should] beNonNil];
                            
                             [[searchedCheckin.comment should] equal:@"my checkin to search"];
                         }
                         
                         fin = YES;
                     }];
                    
                }];
                
            }];
            [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
        });
        
    
    it(@"Should allow uploading a picture", ^{
        
        __block BOOL fin = NO;
        NSMutableDictionary *pic = [NSMutableDictionary new];
        
        [pic setObject:@"Pic from iOS" forKey:@"caption"];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *imagePath = [bundle pathForResource:@"test" ofType:@"png"];
        
        
        BPFile *file = [BPFile new];
        file.fileData = [[NSFileManager defaultManager] contentsAtPath:imagePath];
        file.contentType = @"image/png";
        
        [pic setObject:file forKey:@"data"];
        
        [Buddy POST:@"pictures" parameters:pic class:[NSDictionary class] callback:^(id obj, NSError *error) {
            [[error should] beNil];
            if(error!=nil)
            {
                return;
            }
            
            NSDictionary *result = (NSDictionary*)obj;
            [[result should] beNonNil];
            
            NSString *picId = [result objectForKey:@"id"];
            [[picId should] beNonNil];
            
            NSString *caption = [result objectForKey:@"caption"];
            [[caption should] equal:@"Pic from iOS"];
             
             NSString *contentType = [result objectForKey:@"contentType"];
             [[contentType should] equal: @"image/png"];
            
            fin = YES;
            
        }];
        [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
    });
    
    it(@"Should allow patching a picture", ^{
        
        __block BOOL fin = NO;
        NSMutableDictionary *pic = [NSMutableDictionary new];
        
        [pic setObject:@"Pic from iOS" forKey:@"caption"];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *imagePath = [bundle pathForResource:@"test" ofType:@"png"];
        
        
        BPFile *file = [BPFile new];
        file.fileData = [[NSFileManager defaultManager] contentsAtPath:imagePath];
        file.contentType = @"image/png";
        
        [pic setObject:file forKey:@"data"];
        
        [Buddy POST:@"pictures" parameters:pic class:[NSDictionary class] callback:^(id obj, NSError *error) {
            [[error should] beNil];
            if(error!=nil)
            {
                return;
            }
            
            NSDictionary *result = (NSDictionary*)obj;
            [[result should] beNonNil];
            
            NSString *picId = [result objectForKey:@"id"];
            [[picId should] beNonNil];
            
            NSString *caption = [result objectForKey:@"caption"];
            [[caption should] equal:@"Pic from iOS"];
            
            NSString *contentType = [result objectForKey:@"contentType"];
            [[contentType should] equal: @"image/png"];
            
            NSDictionary *patchParams = @{@"caption" : @"The patched Caption"};
            
            [Buddy PATCH:[NSString stringWithFormat:@"/pictures/%@",picId] parameters:patchParams class:[NSDictionary class]
                callback:^(id secondObj, NSError *error) {
                    [[error should] beNil];
                    if(error!=nil)
                    {
                        return;
                    }
                    
                    [Buddy GET:[NSString stringWithFormat:@"/pictures/%@",picId] parameters:nil class:[NSDictionary class] callback:^(id patchObj,  NSError *error)
                    {
                        [[error should] beNil];
                        if(error!=nil)
                        {
                            return;
                        }
                        
                        NSDictionary *patchResult = (NSDictionary*)patchObj;
                        [[patchResult should] beNonNil];
                        
                        NSString *patchCaption = [patchResult objectForKey:@"caption"];
                        [[patchCaption should] equal:@"The patched Caption"];
                        
                        fin = YES;
                    }];
                    
                }];
        }];
        [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
    });
    
    it(@"Should allow getting a picture", ^{
        
        __block BOOL fin = NO;
        NSMutableDictionary *pic = [NSMutableDictionary new];
        
        [pic setObject:@"Pic from iOS" forKey:@"caption"];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *imagePath = [bundle pathForResource:@"test" ofType:@"png"];
        
        
        BPFile *file = [BPFile new];
        file.fileData = [[NSFileManager defaultManager] contentsAtPath:imagePath];
        file.contentType = @"image/png";
        
        [pic setObject:file forKey:@"data"];
        
        [Buddy POST:@"pictures" parameters:pic class:[NSDictionary class] callback:^(id obj, NSError *error) {
            [[error should] beNil];
            if(error!=nil)
            {
                return;
            }
            
            NSDictionary *result = (NSDictionary*)obj;
            [[result should] beNonNil];
            
            NSString *picId = [result objectForKey:@"id"];
            [[picId should] beNonNil];
            
            NSString *caption = [result objectForKey:@"caption"];
            [[caption should] equal:@"Pic from iOS"];
            
            NSString *contentType = [result objectForKey:@"contentType"];
            [[contentType should] equal: @"image/png"];
            
            
            [Buddy GET:[NSString stringWithFormat:@"pictures/%@",picId] parameters:nil class:[NSDictionary class]
                callback:^(id obj, NSError *error) {
                    [[error should] beNil];
                    if(error!=nil)
                    {
                        return;
                    }
                    
                    NSDictionary *getResult = (NSDictionary*)obj;
                    [[result should] beNonNil];
                    
                    NSString *getPicId = [getResult objectForKey:@"id"];
                    [[getPicId should] equal:picId];
                    
                    NSString *getPicCaption = [getResult objectForKey:@"caption"];
                    [[getPicCaption should] equal:@"Pic from iOS"];
                    
                    NSString *getPicContentType = [getResult objectForKey:@"contentType"];
                    [[getPicContentType should] equal: @"image/png"];
                    
                    fin = YES;
                }];
        }];
        [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
    });
    
    it(@"Should allow getting a picture binary data", ^{
        
        __block BOOL fin = NO;
        NSMutableDictionary *pic = [NSMutableDictionary new];
        
        [pic setObject:@"Pic from iOS" forKey:@"caption"];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *imagePath = [bundle pathForResource:@"test" ofType:@"png"];
        
        
        BPFile *file = [BPFile new];
        file.fileData = [[NSFileManager defaultManager] contentsAtPath:imagePath];
        file.contentType = @"image/png";
        
        [pic setObject:file forKey:@"data"];
        
        [Buddy POST:@"pictures" parameters:pic class:[NSDictionary class] callback:^(id obj, NSError *error) {
            [[error should] beNil];
            if(error!=nil)
            {
                return;
            }
            
            NSDictionary *result = (NSDictionary*)obj;
            [[result should] beNonNil];
            
            NSString *picId = [result objectForKey:@"id"];
            [[picId should] beNonNil];
            
            NSString *caption = [result objectForKey:@"caption"];
            [[caption should] equal:@"Pic from iOS"];
            
            NSString *contentType = [result objectForKey:@"contentType"];
            [[contentType should] equal: @"image/png"];
            
            
            [Buddy GET:[NSString stringWithFormat:@"pictures/%@/file",picId] parameters:nil class:[BPFile class]
              callback:^(id obj, NSError *error) {
                  [[error should] beNil];
                  if(error!=nil)
                  {
                      return;
                  }
                  
                  BPFile *fileData = (BPFile*)obj;
                  
                  [[fileData.contentType should] equal:@"image/png"];
                  [[fileData.fileData should] beNonNil];
                  
                  fin = YES;
              }];
        }];
        [[expectFutureValue(theValue(fin)) shouldEventually] beYes];
    });
   
    });
});
SPEC_END
