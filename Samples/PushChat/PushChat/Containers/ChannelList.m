//
//  ChannelListItem.m
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <BuddySDK/Buddy.h>

#import "ChannelList.h"

@implementation ChannelList


-(instancetype)init
{
    {
        self = [super init];
        if (self)
        {
            _channels = [[NSMutableDictionary alloc] init];
        }
        return self;
    }
}

-(void) clearChannels
{
    [self.channels removeAllObjects];
}
-(void) addChannel:(BPModelUserList*)channel
{
    [self.channels setObject:channel forKey:channel.id];
    
}

-(int) channelCount
{
    return [self.channels count];
}

-(BPModelUserList*) getChannel:(NSString*)channelID
{
    return [self.channels objectForKey:channelID];
}

@end
