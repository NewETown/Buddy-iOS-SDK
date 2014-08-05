//
//  MainViewController.m
//  registerlogin
//
//  Created by Nick Ambrose on 1/15/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MBProgressHUD.h"

#import <BuddySDK/Buddy.h>

#import "Constants.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "ChangeProfilePictureViewController.h"
#import "ChangeNameBirthdayVC.h"
#import "SearchUsersViewController.h"

#import <BuddySDK/Buddy.h>

@interface MainViewController ()

@property (nonatomic,strong) MBProgressHUD *HUD;

- (RESTCallback) getRefreshCallback;
- (RESTCallback) getDeleteCallback;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setTitle:@"Buddy User Accounts Sample"];
    UIBarButtonItem *backButton =[[UIBarButtonItem alloc] initWithTitle:@"Logout"  style:UIBarButtonItemStylePlain target:self action:@selector(doLogout)];
    
    
    self.navigationItem.leftBarButtonItem = backButton;
    }

- (void) updateFields
{
    
    
    if (Buddy.user.firstName && Buddy.user.lastName) {
        self.mainLabel.text = [NSString stringWithFormat:@"Hi %@ %@",
                           Buddy.user.firstName, Buddy.user.lastName];
    }
    else {
        self.mainLabel.text = [NSString stringWithFormat:@"Hi %@",
                               Buddy.user.userName];
    }
    
}

- (RESTCallback) getRefreshCallback
{
    MainViewController * __weak weakSelf = self;
    
    return ^(id obj,NSError *error)
    {
        [weakSelf.HUD hide:TRUE afterDelay:0.1];
        self.HUD=nil;
        
        if(error!=nil)
        {
            BPModelUser *user = (BPModelUser*)obj;
            
            
            Buddy.user = user;
        }
    };
}

- (void)doLogout
{
    [Buddy logoutUser:^(NSError *error)
     {
         NSLog(@"Logout Callback Called");
     }];
 
    [CommonAppDelegate authorizationNeedsUserLogin];
}

- (IBAction)doRefresh:(id)sender
{
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText= @"Refresh";
    self.HUD.dimBackground = YES;
    self.HUD.delegate=self;
    
    [Buddy GET:@"users/me" parameters:nil class:[BPModelUser class] callback:[self getRefreshCallback]];
    
}

- (IBAction)doClearUser:(id)sender
{
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText= @"Clear User";
    self.HUD.dimBackground = YES;
    self.HUD.delegate=self;

    [Buddy logoutUser:^(NSError *error)
     {
         [self.HUD hide:TRUE afterDelay:0.1];
         self.HUD=nil;
         Buddy.user=nil;
     }];

    [CommonAppDelegate authorizationNeedsUserLogin];
}

- (IBAction)doChangeProfilePicture:(id)sender
{
    ChangeProfilePictureViewController *subVC = [[ChangeProfilePictureViewController alloc]
                                            initWithNibName:@"ChangeProfilePictureViewController" bundle:nil];
    
    [ [CommonAppDelegate navController] pushViewController:subVC animated:YES];
}

- (IBAction)doChangeNameBirthday:(id)sender
{
    ChangeNameBirthdayVC *subVC = [[ChangeNameBirthdayVC alloc]
                                                 initWithNibName:@"ChangeNameBirthdayVC" bundle:nil];
    
    [ [CommonAppDelegate navController] pushViewController:subVC animated:YES];
}

- (IBAction)doSearchUsers:(id)sender
{
    SearchUsersViewController *subVC = [[SearchUsersViewController alloc]
                                   initWithNibName:@"SearchUsersViewController" bundle:nil];
    
    [ [CommonAppDelegate navController] pushViewController:subVC animated:YES];
}




- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.HUD.labelText= @"Deleting...";
        self.HUD.dimBackground = YES;
        self.HUD.delegate=self;
        
        [Buddy DELETE:@"users/me" parameters:nil class:[NSDictionary class] callback:[self getDeleteCallback]];
	}
}

- (IBAction)doDeleteUser:(id)sender
{
    
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete User?"
                                                   message:@"Are you sure you want to delete your user account?  This cannot be undone!"
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    [alert show];
    
    
}

- (RESTCallback) getDeleteCallback
{
    MainViewController * __weak weakSelf = self;
    
    return ^(id obj,NSError *error)
    {
        [weakSelf.HUD hide:TRUE afterDelay:0.1];
        weakSelf.HUD=nil;
        
        if(error!=nil)
        {
            NSLog(@"Deleting user - error Called");
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Deleting user"
                                       message: [error localizedDescription]
                                      delegate: self
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        Buddy.user=nil;
        
        NSLog(@"Deleting user - success Called");
        [CommonAppDelegate authorizationNeedsUserLogin];
    };
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateFields];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(self.HUD!=nil)
    {
        [self.HUD hide:TRUE afterDelay:0.1];
        self.HUD=nil;
    }
    if (self.isMovingFromParentViewController)
    {
        [Buddy logoutUser:nil];
    }
}



@end
