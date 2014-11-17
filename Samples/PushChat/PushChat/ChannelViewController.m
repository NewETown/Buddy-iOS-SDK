//
//  ChannelViewController.m
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <BuddySDK/Buddy.h>

#import "Constants.h"
#import "AppDelegate.h"

#import "ChannelViewController.h"

@interface ChannelViewController ()

@property (nonatomic,strong) BPUserList *channel;
@end

@implementation ChannelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil channel:(BPUserList*)channel
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.joinBut.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.joinBut.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.joinBut.layer.borderColor = [UIColor blackColor].CGColor;
    self.joinBut.clipsToBounds = YES;
    
    self.leaveBut.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.leaveBut.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.leaveBut.layer.borderColor = [UIColor blackColor].CGColor;
    self.leaveBut.clipsToBounds = YES;

    
    self.deleteBut.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.deleteBut.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.deleteBut.layer.borderColor = [UIColor blackColor].CGColor;
    self.deleteBut.clipsToBounds = YES;

    if(self.channel!=nil)
    {
        self.channelName.text = self.channel.name;
    }
    else
    {
        self.channelName.text = @"Error Happened";
    }
}

-(IBAction)deleteList:(id)sender
{
    __weak ChannelViewController *weakSelf = self;
    
    [Buddy DELETE: [NSString stringWithFormat:@"users/lists/%@",self.channel.id] parameters:nil class:[NSDictionary class] callback:^(id obj, NSError *error) {
        if(error!=nil)
        {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Server error"
                                       message: [error localizedDescription]
                                      delegate: weakSelf
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;
        }
        [[CommonAppDelegate navController] popViewControllerAnimated:YES];
    }];
}

-(IBAction)join:(id)sender
{
    __weak ChannelViewController  *weakSelf=self;
    if(self.channel==nil)
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Server error"
                               message: @"List Was Not Set"
                              delegate: self
                     cancelButtonTitle: @"OK"
                     otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [Buddy PUT: [NSString stringWithFormat:@"users/lists/%@/items/%@",self.channel.id,[Buddy user].id]
     parameters:nil class:[NSNumber class] callback:^(id obj, NSError *error) {
    
        if(error!=nil)
        {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Server error"
                                       message: [error localizedDescription]
                                      delegate: weakSelf
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;

        }
         
         NSNumber *numberResult = (NSNumber*)obj;
         
         
         BOOL result = NO;
         if([numberResult isEqualToNumber:[NSNumber numberWithInt:1]])
         {
             result=YES;
         }
        
        if(result==NO)
        {
        
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Already On"
                                       message: @"You were already on that list"
                                      delegate: weakSelf
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;

        }
        
         
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Joined"
                                   message: @"You joined the list"
                                  delegate: weakSelf
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;

    }];
}

-(IBAction)leave:(id)sender
{
    __weak ChannelViewController  *weakSelf=self;
    if(self.channel==nil)
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Server error"
                                   message: @"List Was Not Set"
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [Buddy DELETE:[NSString stringWithFormat:@"users/lists/%@/items/%@",self.channel.id,[Buddy user].id] parameters:nil class:[NSNumber class] callback:^(id obj, NSError *error) {
        
        if(error!=nil)
        {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Server error"
                                       message: [error localizedDescription]
                                      delegate: weakSelf
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;
            
        }
        
        NSNumber *numberResult = (NSNumber*)obj;
        
        
        BOOL result = NO;
        if([numberResult isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            result=YES;
        }
        
        
        if(result==NO)
        {
            
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: @"Not On List"
                                       message: @"You were not on that list"
                                      delegate: weakSelf
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alert show];
            return;
            
        }
        
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Left List"
                                   message: @"You left the list"
                                  delegate: weakSelf
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
