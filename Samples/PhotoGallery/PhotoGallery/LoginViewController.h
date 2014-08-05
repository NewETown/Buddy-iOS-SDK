//
//  LoginViewController.h
//  PhotoGallery
//
//  Created by Nick Ambrose on 1/22/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

@interface LoginViewController : UIViewController <MBProgressHUDDelegate>

@property (nonatomic,weak) IBOutlet UITextField *userNameTextField;
@property (nonatomic,weak) IBOutlet UITextField *passwordTextField;

@property (nonatomic,weak) IBOutlet UIButton *loginBut;
@property (nonatomic,weak) IBOutlet UIButton *goRegisterBut;

-(IBAction) doLogin:(id)sender;
-(IBAction) goRegister:(id)sender;



@end

