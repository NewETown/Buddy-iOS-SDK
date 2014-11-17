//
//  BPMetadataItem.h
//  BuddySDK
//
//  Created by Nick Ambrose on 8/26/14.
//
//

#import "BPModelBase.h"

@class BPCoordinate;

@interface BPMetadataItem : BPModelBase

@property (nonatomic,strong) NSString *key;
@property (nonatomic,strong) NSString *value;
@property (nonatomic,strong) BPCoordinate *location;
@property (nonatomic,strong) NSDate *created;
@property (nonatomic,strong) NSDate *lastModified;

@end
