//
//  BPBinaryModelBase.h
//  BuddySDK
//
//  Created by Nick Ambrose on 8/26/14.
//
//

#import "BPModelBase.h"

@interface BPBinaryModelBase : BPModelBase

@property (nonatomic,strong) NSString *contentType;
@property (nonatomic,assign) int contentLength;
@property (nonatomic,strong) NSString *signedUrl;

@end
