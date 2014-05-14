//
//  BPAlbumItemCollection.m
//  BuddySDK
//
//  Created by Erik Kerber on 1/25/14.
//
//

#import "BPAlbumItemCollection.h"
#import "BuddyCollection+Private.h"
#import "BPAlbumItem.h"

@interface BPAlbumItemCollection()

@property (nonatomic, weak) BPAlbum *album;

@end

@implementation BPAlbumItemCollection

- (instancetype)initWithAlbum:(BPAlbum *)album andClient:(id<BPRestProvider>)client
{
    self = [super initWithClient:client];
    if (self) {
        self.type = [BPAlbumItem class];
        _album = album;
    }
    return self;
}

- (NSString *)requestPrefix
{
    return [NSString stringWithFormat:@"albums/%@/", self.album.id];
}

- (void)addAlbumItem:(BPAlbumItem *)albumItem
            withItem:(BuddyObject<BPAlbumItem> *)itemToAdd
            callback:(BuddyCompletionCallback)callback
{
    
    id params = [albumItem buildUpdateDictionary];
    
    // Special ID field name.
    params = [NSDictionary dictionaryByMerging:params with:@{@"ItemId": itemToAdd.id}];
    
    NSString *requestPath = [self.requestPrefix stringByAppendingString:[[self type] requestPath]];
    
    [self.client POST:requestPath parameters:params callback:^(id json, NSError *error) {
        [[JAGPropertyConverter converter] setPropertiesOf:albumItem fromDictionary:json];
        callback(error);
    }];
}

- (void)searchAlbumItems:(BPSearchAlbumItems *)searchAlbumItems callback:(BuddyObjectCallback)callback
{
    id parameters = [searchAlbumItems parametersFromProperties:@protocol(BPAlbumItemProperties)];
    
    [self search:parameters callback:callback];
}


- (void)getAlbumItem:(NSString *)itemId
            callback:(BuddyObjectCallback)callback
{
    [self getItem:itemId callback:callback];
}
@end
