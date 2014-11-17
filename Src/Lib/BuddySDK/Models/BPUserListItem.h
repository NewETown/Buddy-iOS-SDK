//
//  BPUserListItem.h
//  BuddySDK
//
//  Created by Nick Ambrose on 8/26/14.
//
//

#import "BPModelBase.h"

#define BP_USER_LIST_ITEM_TYPE_USER @"User"
#define BP_USER_LIST_ITEM_TYPE_USER_LIST @"UserList"

@interface BPUserListItem : BPModelBase

@property (nonatomic,strong) NSString *itemType;

@end
