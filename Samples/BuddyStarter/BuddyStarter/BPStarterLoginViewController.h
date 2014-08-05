//
//  LoginViewController.h
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BPStarterLoginViewController : UIViewController <UITextFieldDelegate>


// login
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (nonatomic,weak) IBOutlet UITextField *loginUsername;
@property (nonatomic,weak) IBOutlet UITextField *loginPassword;

- (IBAction)loginDidClick:(id)sender;

// signup

@property (weak, nonatomic) IBOutlet UIView *signupView;

@property (weak, nonatomic) IBOutlet UITextField *signupUsername;
@property (weak, nonatomic) IBOutlet UITextField *signupEmail;

@property (weak, nonatomic) IBOutlet UITextField *signupFirstName;

@property (weak, nonatomic) IBOutlet UITextField *signupLastName;


@property (weak, nonatomic) IBOutlet UITextField *signupPassword;

@property (weak, nonatomic) IBOutlet UITextField *signupConfirmPassword;




@property (nonatomic,weak) IBOutlet UIButton *loginBut;

- (IBAction)signupDidClick:(id)sender;




@property (weak, nonatomic) IBOutlet UISegmentedControl *loginChooser;

@end
