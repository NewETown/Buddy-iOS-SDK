//
//  UIChannelListTable.h
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewChannelListItem;

@interface ViewChannelListTable : NSObject

@property (nonatomic,strong) NSMutableArray *table;

-(void) addItem:(ViewChannelListItem*)item;
-(void) clear;

-(NSUInteger) itemCount;

@end
