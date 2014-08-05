//
//  UserDetailViewController.h
//  registerlogin
//
//  Created by devmania on 3/28/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class BPModelUser;

@interface UserDetailViewController : UIViewController<MBProgressHUDDelegate>

@property (retain) BPModelUser *user;

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;


@end
