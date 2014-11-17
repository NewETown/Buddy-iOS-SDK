//
//  BPAlbumItem.h
//  BuddySDK
//
//  Created by Nick Ambrose on 8/26/14.
//
//

#import "BPModelBase.h"

#define BP_ALBUM_ITEM_TYPE_PICTURE @"Picture"
#define BP_ALBUM_ITEM_TYPE_VIDEO @"Video"

@interface BPAlbumItem : BPModelBase

@property (nonatomic,strong) NSString *itemType;
@property (nonatomic,strong) NSString *caption;
@property (nonatomic,strong) NSString *itemId;

@end
