//
//  UIChannelListTable.m
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import "ViewChannelListTable.h"

@implementation ViewChannelListTable

-(instancetype)init
{
    {
        self = [super init];
        if (self)
        {
            _table = [[NSMutableArray alloc] init];
        }
        return self;
    }
}

-(void) addItem:(ViewChannelListItem*)item
{
    [self.table addObject:item];
}
-(void) clear
{
    [self.table removeAllObjects];
}

-(NSUInteger) itemCount
{
    return [self.table count];
}

@end
