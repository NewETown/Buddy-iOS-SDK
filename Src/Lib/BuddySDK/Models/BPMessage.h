//
//  BPMessage.h
//  BuddySDK
//
//  Created by Nick Ambrose on 8/26/14.
//
//

#import "BPModelBase.h"

@interface BPMessage : BPModelBase

@property (nonatomic,strong) NSString *subject;
@property (nonatomic,strong) NSString *body;
@property (nonatomic,strong) NSString *thread;
@property (nonatomic,strong) NSString *fromUserId;
@property (nonatomic,strong) NSString *toUserId;
@property (nonatomic,strong) NSString *toUserName;
@property (nonatomic,strong) NSDate *sent;
@property (nonatomic,strong) NSArray *recipients;
@property (nonatomic,assign) BOOL isNew;
@property (nonatomic,strong) NSDictionary *warnings;

@end
