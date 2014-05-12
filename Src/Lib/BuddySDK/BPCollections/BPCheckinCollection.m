//
//  BPCheckinCollection.m
//  BuddySDK
//
//  Created by Erik Kerber on 11/15/13.
//
//

#import "BPCheckinCollection.h"
#import "BPCheckin.h"
#import "BPClient.h"
#import "BuddyCollection+Private.h"
#import "BuddyObject+Private.h"
#import "BPSisterObject.h"
#import "BuddyObject+Private.h"

@implementation BPCheckinCollection

- (instancetype)initWithClient:(id<BPRestProvider>)client {
    self = [super initWithClient:client];
    if(self){
        self.type = [BPCheckin class];
    }
    return self;
}

-(void)addCheckin:(BPCheckin *)checkin
         callback:(BuddyCompletionCallback)callback
{
    [checkin savetoServer:callback];
}

- (void)searchCheckins:(BPSearchCheckins *)searchCheckin callback:(BuddyCollectionCallback)callback;
{
    id parameters = [searchCheckin parametersFromProperties:@protocol(BPCheckinProperties)];
    
    [self search:parameters callback:callback];
}

- (void)getCheckin:(NSString *)checkinId callback:(BuddyObjectCallback)callback
{
    [self getItem:checkinId callback:callback];
}

@end
