//
//  ChannelListItem.h
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BPModelUserList;


@interface ChannelList : NSObject

@property (nonatomic,strong) NSMutableDictionary *channels;

-(void) clearChannels;
-(void) addChannel:(BPModelUserList*)channel;

-(int) channelCount;

-(BPModelUserList*) getChannel:(NSString*)channelID;

@end
