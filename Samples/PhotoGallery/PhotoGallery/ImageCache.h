//
//  ImageCache.h
//  PhotoGallery
//
//  Created by Nick Ambrose on 1/23/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

 

-(void)clear;
-(NSInteger)count;
-(UIImage*)getImageByPictureID:(NSString*)pictureID;

// Replaces whatever is in already with same ID
-(void) addImage:(UIImage*)image withPictureID:(NSString*)pictureID;

// Could return BOOL to indicate if image was actually present to remove
-(void) removeImageByID:(NSString*)pictureID;

@end
