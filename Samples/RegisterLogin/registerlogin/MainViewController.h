//
//  MainViewController.h
//  registerlogin
//
//  Created by Nick Ambrose on 1/15/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MainViewController : UIViewController <MBProgressHUDDelegate>

@property (nonatomic,weak) IBOutlet UILabel *mainLabel;

@property (nonatomic,weak) IBOutlet UILabel *emailLabel;

@property (nonatomic,weak) IBOutlet UIButton *refreshBut;
@property (nonatomic,weak) IBOutlet UIButton *clearUserBut;
@property (weak, nonatomic) IBOutlet UIButton *changeProfilePictureBut;
@property (weak, nonatomic) IBOutlet UIButton *changeNameBirthdayBut;
@property (weak, nonatomic) IBOutlet UIButton *searchUserBut;
@property (weak, nonatomic) IBOutlet UIButton *deleteUserBut;

- (void)updateFields;

- (IBAction)doRefresh:(id)sender;
- (IBAction)doClearUser:(id)sender;
- (IBAction)doChangeProfilePicture:(id)sender;
- (IBAction)doChangeNameBirthday:(id)sender;
- (IBAction)doSearchUsers:(id)sender;
- (IBAction)doDeleteUser:(id)sender;
- (void)doLogout;



@end
