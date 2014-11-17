//
//  PictureList.h
//  PhotoGallery
//
//  Created by Nick Ambrose on 1/23/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BPPicture;

/* We could consider a higher-level class that automates fetching an Image for a picture if it does not exist and uses callbacks. For now, keeping it basic
 */

@interface PictureList : NSObject

// For large numbers of pictures this would be better as a dictionary but then need a mapping in the LayoutView.
@property (nonatomic,strong) NSMutableArray *pictureList;

-(void)clearAndImages:(BOOL)andImages;
-(NSInteger)count;

-(void)putPictures:(NSMutableArray *)pictures;
-(BPPicture*)getPictureByID:(NSString*)pictureID;
-(BPPicture*)pictureAtIndex:(NSInteger)index;
-(void) addPicture:(BPPicture*)picture;

// Uses picture.id to remove
-(void) removePicture:(BPPicture*)picture andImage:(BOOL) andImage;

-(void) removePictureByID:(NSString*)pictureID andImage:(BOOL) andImage;


-(void)clearImagesOnly;
-(NSInteger)countImages;
-(UIImage*)getImageByPictureID:(NSString*)pictureID;

// Replaces whatever is in already with same ID
-(void) addImage:(UIImage*)image withPictureID:(NSString*)pictureID;

// Could return BOOL to indicate if image was actually present to remove
-(void) removeImageByID:(NSString*)pictureID;


@end
