//
//  LoginViewController.h
//  registerlogin
//
//  Created by Nick Ambrose on 1/14/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

@interface LoginViewController : UIViewController <MBProgressHUDDelegate, UITextFieldDelegate>

@property (nonatomic,weak) IBOutlet UITextField *userNameTextField;
@property (nonatomic,weak) IBOutlet UITextField *passwordTextField;

@property (nonatomic,weak) IBOutlet UIButton *loginBut;
@property (weak, nonatomic) IBOutlet UIButton *socialLoginBut;
@property (nonatomic,weak) IBOutlet UIButton *goRegisterBut;

-(IBAction) doLogin:(id)sender;
-(IBAction) doSocialLogin:(id)sender;
-(IBAction) goRegister:(id)sender;

-(void) populateFields;
-(void) resignTextFields;

@end
