//
//  BPModelUser.h
//  BuddySDK
//
//  Created by Nick Ambrose on 7/17/14.
//
//

#import "BPModelBase.h"

@interface BPModelUser : BPModelBase

@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *firstName;
@property (nonatomic,strong) NSString *lastName;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSDate *dateOfBirth;
@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSString *profilePictureID;

@end
