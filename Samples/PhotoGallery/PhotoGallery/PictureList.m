//
//  PictureList.m
//  PhotoGallery
//
//  Created by Nick Ambrose on 1/23/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <BuddySDK/Buddy.h>

#import "PictureList.h"
#import "ImageCache.h"

@interface PictureList ()

@property (nonatomic,strong) ImageCache *cache;

-(NSInteger) findIndexOfPictureByID:(NSString*)pictureID;

@end

@implementation PictureList

-(instancetype)init
{
    {
        self = [super init];
        if (self)
        {
            _pictureList = [[NSMutableArray alloc] init];
            _cache = [[ImageCache alloc] init];
        }
        return self;
    }
}

-(void)clearAndImages:(BOOL)andImages
{
    [self.pictureList removeAllObjects];
    if(andImages)
    {
        [self clearImagesOnly];
    }
}

-(NSInteger)count
{
    return [self.pictureList count];
}

-(void)putPictures:(NSMutableArray *)pictures
{
    self.pictureList = pictures;
}

-(BPPicture*)getPictureByID:(NSString*)pictureID
{
    if(pictureID==nil)
    {
        return nil;
    }
    
    for(BPPicture *picture in self.pictureList)
    {
        if([pictureID compare:picture.id]==0 )
        {
            return picture;
        }
    }
    return nil;
}

-(void) addPicture:(BPPicture*)picture
{
    if(self.pictureList==nil)
    {
        return;
    }
    
    if( [self getPictureByID:picture.id]!=nil)
    {
        // Already present by ID, dont add.
        return;
    }
    [self.pictureList addObject:picture];
}

-(BPPicture*)pictureAtIndex:(NSInteger)index
{
    if(index< [self count])
    {
        return [self.pictureList objectAtIndex:index];
    }
    return nil;
}

-(NSInteger) findIndexOfPictureByID:(NSString*)pictureID
{
    if(pictureID==nil)
    {
        return NSNotFound;
    }
    
    NSInteger index=0;
    for(BPPicture *picture in self.pictureList)
    {
        if([pictureID isEqualToString:picture.id])
        {
            return index;
        }
        index++;
    }
    return NSNotFound;
}

-(void) removePicture:(BPPicture*)picture andImage:(BOOL) andImage
{
    NSInteger pictureIndex = [self findIndexOfPictureByID:picture.id];
    if(pictureIndex!=NSNotFound)
    {
        [self.pictureList removeObjectAtIndex:pictureIndex];
    }
    if(andImage)
    {
        [self.cache removeImageByID:picture.id];
    }
}

-(void) removePictureByID:(NSString*)pictureID andImage:(BOOL) andImage
{
    NSInteger pictureIndex = [self findIndexOfPictureByID:pictureID];
    if(pictureIndex!=NSNotFound)
    {
        [self.pictureList removeObjectAtIndex:pictureIndex];
    }
    
    if(andImage)
    {
        [self.cache removeImageByID:pictureID];
    }
}

-(void)clearImagesOnly
{
    [self.cache clear];
}
-(NSInteger)countImages
{
    return [self.cache count];
}

-(UIImage*)getImageByPictureID:(NSString*)pictureID
{
    return [self.cache getImageByPictureID:pictureID];
}

-(void) addImage:(UIImage*)image withPictureID:(NSString*)pictureID
{
    [self.cache addImage:image withPictureID:pictureID];
}

-(void) removeImageByID:(NSString*)pictureID
{
    [self.cache removeImageByID:pictureID];
}

@end
