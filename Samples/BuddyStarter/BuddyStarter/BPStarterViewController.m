//
//  BPStarterViewController.m
//
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import "BPStarterViewController.h"
#import <BuddySDK/Buddy.h>

@interface BPStarterViewController ()


@end

@implementation BPStarterViewController
@synthesize message;
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.message.text = @"Loading...";
    
}

-(void)refreshUser {
    
    [Buddy GET:@"users/me" parameters:nil class:[BPModelUser class] callback:^(id u, NSError *error) {
        BPModelUser *user = u;
        if (user && user.userName) {
            self.message.text = [[NSString alloc] initWithFormat:@"Hello, %@.", user.userName];
        }
        else {
            self.message.text = @"";
        }
       
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    
    self.message.text = @"Loading...";
    
    BPModelUser *user = [Buddy user];
    
    // load the current user's information
    //
    [self refreshUser];
}



- (IBAction)logoutWasClicked:(id)sender {
    __weak BPStarterViewController *weakSelf = self;

    self.message.text = @"";

    [Buddy logoutUser:^(NSError *error) {
        
        // calling check user will cause the login dialog to pop
        // when user auth fails.
        [weakSelf refreshUser];
    }];
}
@end
