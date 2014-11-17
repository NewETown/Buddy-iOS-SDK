//
//  BPVideo.h
//  BuddySDK
//
//  Created by Nick Ambrose on 8/26/14.
//
//

#import "BPBinaryModelBase.h"

@interface BPVideo : BPBinaryModelBase

@property (nonatomic,strong) NSString *encoding;
@property (nonatomic,assign) int bitRate;
@property (nonatomic,assign) double lengthInSeconds;
@property (nonatomic,strong) NSString *thumbnailID;

@end
