//
//  BPAlbumItemCollection.h
//  BuddySDK
//
//  Created by Erik Kerber on 1/25/14.
//
//

#import "BuddyCollection.h"
#import "BPAlbum.h"
#import "BPAlbumItem.h"

@interface BPAlbumItemCollection : BuddyCollection

- (instancetype)initWithClient:(id<BPRestProvider>)client __attribute__((unavailable("Use initWithAlbum:andClient:")));;
- (instancetype)initWithAlbum:(BPAlbum *)album andClient:(id<BPRestProvider>)client;

- (void)addAlbumItem:(BPAlbumItem *)albumItem
            withItem:(BuddyObject<BPAlbumItem> *)itemToAdd
            callback:(BuddyCompletionCallback)callback;

- (void)searchAlbumItems:(BPSearchAlbumItems *)searchAlbumItems callback:(BuddyObjectCallback)callback;

- (void)getAlbumItem:(NSString *)pictureId callback:(BuddyObjectCallback)callback;

    
@end
