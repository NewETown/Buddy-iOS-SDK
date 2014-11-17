//
//  ImageCache.m
//  PhotoGallery
//
//  Created by Nick Ambrose on 1/23/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import "ImageCache.h"
@interface ImageCache ()
@property (nonatomic,strong) NSMutableDictionary *imageCache;
@end

@implementation ImageCache

-(instancetype)init
{
    {
        self = [super init];
        if (self)
        {
            _imageCache = [[NSMutableDictionary alloc] init];
        }
        return self;
    }
}

-(void)clear
{
    [self.imageCache removeAllObjects];
}

-(NSInteger)count
{
    return [self.imageCache count];
}

-(UIImage*)getImageByPictureID:(NSString*)pictureID
{
    return [self.imageCache objectForKey:pictureID];
}

-(void) addImage:(UIImage*)image withPictureID:(NSString*)pictureID
{
    [self.imageCache setObject:image forKey:pictureID];
}

-(void) removeImageByID:(NSString*)pictureID
{
    [self.imageCache removeObjectForKey:pictureID];
}


@end
