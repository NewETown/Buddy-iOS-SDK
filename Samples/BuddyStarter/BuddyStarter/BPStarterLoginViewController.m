//
//  LoginViewController.m
//
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <UIKit/UIKit.h>
#import <BuddySDK/Buddy.h>
#import "BPStarterLoginViewController.h"


@interface BPStarterLoginViewController ()


-(BuddyObjectCallback) getLoginCallback;

@end



@implementation BPStarterLoginViewController

@synthesize loginUsername;
@synthesize loginPassword;
@synthesize signupConfirmPassword;
@synthesize signupEmail;
@synthesize signupFirstName;
@synthesize signupLastName;
@synthesize signupPassword;

@synthesize loginView;
@synthesize signupView;

@synthesize loginChooser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up our Login / Signup Selector
    [loginChooser addTarget:self action:@selector(didChangeLoginType) forControlEvents:UIControlEventValueChanged];
    
    [self didChangeLoginType];
}

-( void) viewDidAppear:(BOOL)animated   {
    
    [super viewDidAppear:animated];
    
    // align the signup view to the same position as the login view
    //
    CGRect signupFrame = [signupView frame];
    
    signupFrame.origin.y = loginView.frame.origin.y;
    signupView.frame = signupFrame;
  
    
}

- (void) didChangeLoginType {
    
    // hide show the appropraite view
    switch (loginChooser.selectedSegmentIndex) {
        case 0:
            [loginView setHidden:FALSE];
            [signupView setHidden:TRUE];
            break;
        case 1:
            [loginView setHidden:TRUE];
            [signupView setHidden:FALSE];
            break;
    }
    

}

// we do this rather than a direct method to avoid
// holding a refence in the handler blocks
//
-(BuddyObjectCallback) getLoginCallback
{
    __weak BPStarterLoginViewController *weakSelf = self;

    return ^(id newBuddyObject, NSError *error)
    {
        if(error!=nil)
        {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Login Error"
                                       message: [error localizedDescription]
                                      delegate: self
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        self.loginPassword.text = @"";
        self.signupConfirmPassword.text = signupPassword.text = @"";
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
    };
}


- (IBAction)signupDidClick:(id)sender {
    
    // handle click on signup
    
    if( [self.signupUsername.text length]==0)
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
    
    if( [self.signupPassword.text length]==0)
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
    
    if (![self.signupPassword.text isEqualToString:self.signupConfirmPassword.text]) {
        
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Password"
                                   message: @"Passwords must match"
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    // build the user details
    // note only username and password are required.
    
    BuddyObjectCallback loginCallback = [self getLoginCallback];
    
    [Buddy createUser:self.signupUsername.text
             password:self.signupPassword.text
            firstName:self.signupFirstName.text
             lastName:self.signupLastName.text
                email:self.signupEmail.text
          dateOfBirth:nil gender:@"male" tag:nil callback:loginCallback];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = textField.frame.origin.y; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    
    // if it's on of the "Go" fields, invoke the appropriate
    // click handler
    if (textField.returnKeyType == UIReturnKeyGo) {
        
        switch (loginChooser.selectedSegmentIndex) {
            case 0:
                [self loginDidClick:nil];
                return NO;
            case 1:
                [self signupDidClick:nil];
                return NO;
        }
    }
    
    // otherwise, walk through to the next item
    //
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}




- (IBAction)loginDidClick:(id)sender {
    
    // handle login click
    //
    
    if( [self.loginUsername.text length]==0)
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
    
    if( [self.loginPassword.text length]==0)
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

    
    [Buddy loginUser:self.loginUsername.text
        password:self.loginPassword.text
        callback:[self getLoginCallback]];

}
@end
