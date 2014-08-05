//
//  LoginViewController.m
//  registerlogin
//
//  Created by Nick Ambrose on 1/14/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <BuddySDK/Buddy.h>

#import "AppDelegate.h"

#import "Constants.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "SocialLoginViewController.h"
#import "MainViewController.h"

@interface LoginViewController ()

@property (nonatomic,strong) MBProgressHUD *HUD;

-(BuddyObjectCallback) getLoginCallback;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
       
    if ([CommonAppDelegate isUsernameSet])
    {
        [self populateFields];
    }
}

-(BuddyObjectCallback) getLoginCallback
{
    LoginViewController * __weak weakSelf = self;
    
    return ^(id newBuddyObject, NSError *error)
    {
        [weakSelf.HUD hide:YES afterDelay:0.1];
        if(error!=nil)
        {
            NSLog(@"Login Callback(error) Called");
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Login Error"
                                       message: [error localizedDescription]
                                      delegate: self
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        NSLog(@"Login Callback(Good) Called");
        
        // Save username and password for next time
        [CommonAppDelegate storeUsername:weakSelf.userNameTextField.text
                             andPassword:weakSelf.passwordTextField.text];
        
        [CommonAppDelegate setLoginPresented:FALSE];
        [[[CommonAppDelegate navController] topViewController] dismissViewControllerAnimated:FALSE completion:nil];
    };
}


-(IBAction) doLogin:(id)sender
{
    [self resignTextFields];
    
    if( [self.userNameTextField.text length]==0)
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Empty Field"
                                   message: @"Username Cannot be empty"
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if( [self.passwordTextField.text length]==0)
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Empty Field"
                                   message: @"Password Cannot be empty"
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    self.HUD.labelText= @"Login";
    self.HUD.dimBackground = YES;
    self.HUD.delegate=self;
    
    [Buddy loginUser:self.userNameTextField.text
        password:self.passwordTextField.text
        callback:[self getLoginCallback]];
    
}

- (IBAction)doSocialLogin:(id)sender {
    NSLog(@"Social Login Called");
    
    
    SocialLoginViewController *socialLoginView = [[SocialLoginViewController alloc] initWithNibName:
                                            @"SocialLoginViewController" bundle:nil];
    
    [[[CommonAppDelegate navController] topViewController] dismissViewControllerAnimated:FALSE completion:nil];
    
    [[[CommonAppDelegate navController] topViewController] presentViewController:socialLoginView animated:FALSE completion:nil];
}

-(IBAction) goRegister:(id)sender
{
    NSLog(@"goRegister Called");
    
    
    RegisterViewController *registerView = [[RegisterViewController alloc] initWithNibName:
                                          @"RegisterViewController" bundle:nil];
    
    [[[CommonAppDelegate navController] topViewController] dismissViewControllerAnimated:FALSE completion:nil];
    
    [[[CommonAppDelegate navController] topViewController] presentViewController:registerView animated:FALSE completion:nil];
}

-(void) resignTextFields
{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textBoxName
{
	[textBoxName resignFirstResponder];
	return YES;
}

-(void) populateFields
{
    if ([CommonAppDelegate isUsernameSet])
    {
        self.userNameTextField.text = [CommonAppDelegate fetchUsername];
    }
    else
    {
        self.userNameTextField.text = @"";
    }
    
    if ([CommonAppDelegate isPasswordSet])
    {
        self.passwordTextField.text = [CommonAppDelegate fetchPassword];
    }
    else
    {
        self.passwordTextField.text = @"";
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
