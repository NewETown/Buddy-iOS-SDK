//
//  BPModelPicture.h
//  BuddySDK
//
//  Created by Nick Ambrose on 7/31/14.
//
//

#import "BPModelBase.h"

@class BPSize;

@interface BPModelPicture : BPModelBase

@property (nonatomic,strong) NSString *caption;
@property (nonatomic, copy) NSString *watermark;
@property (nonatomic, strong) BPSize *size;

@end
