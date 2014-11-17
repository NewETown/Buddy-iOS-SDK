//
//  BPIdentity.h
//  BuddySDK
//
//  Created by Nick Ambrose on 8/26/14.
//
//

#import "BPModelBase.h"

@interface BPIdentity : BPModelBase

@property (nonatomic,strong) NSString *providerName;
@property (nonatomic,strong) NSString *providerID;

@end
