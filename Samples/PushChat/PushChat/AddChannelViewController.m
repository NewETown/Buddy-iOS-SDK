//
//  AddChannelViewController.m
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <BuddySDK/Buddy.h>

#import "Constants.h"
#import "AppDelegate.h"
#import "ChannelList.h"

#import "AddChannelViewController.h"

@interface AddChannelViewController ()

@end

@implementation AddChannelViewController

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
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)addChannel:(id)sender
{
    
    NSDictionary *params =@{@"name" :self.channelName.text,
                           @"readPermissions" : @"App",
                           @"writePermissions" : @"App"};
    
    [Buddy POST:@"users/lists" parameters:params class:[BPUserList class] callback:^(id obj, NSError *error) {
        
        if(error!=nil)
        {
            
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Server error"
                                       message: [error localizedDescription]
                                      delegate: self
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        BPUserList *list = (BPUserList*)obj;
        
        [[CommonAppDelegate channels] addChannel:list];
        
        [Buddy PUT:[NSString stringWithFormat:@"users/lists/%@/items/%@",list.id, [Buddy user].id]
         parameters:nil class:[NSDictionary class] callback:^(id obj, NSError *error)
        {
            [[CommonAppDelegate navController] popViewControllerAnimated:YES];
        }];
        
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
