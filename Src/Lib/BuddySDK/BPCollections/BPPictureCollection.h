//
//  BPPictureCollection.h
//  BuddySDK
//
//  Created by Erik Kerber on 11/22/13.
//
//

#import "BuddyCollection.h"
#import "BPPicture.h"

@interface BPPictureCollection : BuddyCollection

- (void)addPicture:(BPPicture *)picture
             image:(UIImage *)image
          callback:(BuddyCompletionCallback)callback;

- (void)searchPictures:(DescribePicture)describePicture callback:(BuddyCollectionCallback)callback;

- (void)getPicture:(NSString *)pictureId callback:(BuddyObjectCallback)callback;

@end
