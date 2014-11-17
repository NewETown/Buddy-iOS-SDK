//
//  ChangeNameBirthdayVC.m
//  registerlogin
//
//  Created by devmania on 3/27/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import <BuddySDK/Buddy.h>

#import "ChangeNameBirthdayVC.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface ChangeNameBirthdayVC ()

@property (nonatomic,strong) MBProgressHUD *HUD;


- (RESTCallback) getUpdateProfileCallback;

@end

@implementation ChangeNameBirthdayVC

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
    [self setTitle:@"Change Info"];
    
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped:)];
    [[self navigationItem] setRightBarButtonItem:saveButton];
    
    
    self.birthdayPicker.datePickerMode = UIDatePickerModeDate;
    [self populateUI];
}

-(void) populateUI
{
    self.firstNameField.text = [Buddy user].firstName;
    self.lastNameField.text = [Buddy user].lastName;
    
    if ([Buddy user].dateOfBirth)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        self.birthdayField.text = [formatter stringFromDate:[Buddy user].dateOfBirth];
        [self.birthdayPicker setDate:[Buddy user].dateOfBirth];
    }
    else
    {
        self.birthdayField.text = @"Not set yet";
    }
}



- (void)saveButtonTapped:(UIBarButtonItem *)sender
{

    if ([self.firstNameField.text length]==0)
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Notification"
                                   message: @"Please input First Name"
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if ([self.lastNameField.text length]==0)
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Notification"
                                   message: @"Please input Last Name"
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText= @"Saving...";
    self.HUD.dimBackground = YES;
    self.HUD.delegate=self;

    NSDictionary *parameters = @{@"firstName": self.firstNameField.text,
                                 @"lastName": self.lastNameField.text,
                                 @"dateOfBirth" : self.birthdayPicker.date};
    
    [Buddy PATCH:@"users/me" parameters:parameters class:[BPUser class] callback:[self getUpdateProfileCallback]];
}

- (RESTCallback) getUpdateProfileCallback
{
    ChangeNameBirthdayVC * __weak weakSelf = self;
    
    return ^(id obj,NSError *error)
    {
        [weakSelf.HUD hide:TRUE afterDelay:0.1];
        weakSelf.HUD=nil;
        
        if(error!=nil)
        {
            NSLog(@"Change name and birthday - error Called");
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Error Changing name and birthday"
                                       message: [error localizedDescription]
                                      delegate: self
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        BPUser *user = (BPUser*)obj;
        
        Buddy.user = user;
        
        [Buddy setUser:user];
        
        NSLog(@"Change name and birthday - success Called");
        [[self navigationController] popViewControllerAnimated:YES];
    };
}


@end
