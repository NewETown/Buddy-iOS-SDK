//
//  SendMessageViewController.m
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <BuddySDK/Buddy.h>

#import "Constants.h"

#import "AppDelegate.h"
#import "ChannelList.h"

#import "SendMessageViewController.h"

@interface SendMessageViewController ()

@property (nonatomic,strong) NSArray *listsToSendTo;

@end

@implementation SendMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lists:(NSArray*)sendTo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _listsToSendTo = sendTo;
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated
{

}

-(IBAction)sendMessage:(id)sender
{
    __block NSError *savedError=nil;
    for(NSString *listId in self.listsToSendTo)
    {
        BPNotification *notify = [[BPNotification alloc] init];
    
        BPModelUserList *list = [[CommonAppDelegate channels] getChannel:listId];
        if(list==nil)
        {
            continue;
        }
        
        notify.notificationType = BPNotificationType_Alert;
        notify.message = [NSString stringWithFormat:@"%@:%@",list.name,self.message.text ];
        notify.recipients = [NSArray arrayWithObjects:list.id,nil];
        
        [Buddy sendPushNotification:notify callback:^(NSError *error)
        {
            if(error!=nil && savedError==nil)
            {
                savedError=error;
            }
        }];
    }
    
    self.message.text = nil;
    
    if(savedError!=nil)
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Server error"
                                   message: [savedError localizedDescription]
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textBoxName
{
	[textBoxName resignFirstResponder];
	return YES;
}

-(void) resignTextFields
{
    [self.message resignFirstResponder];
}

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
    
    self.sendButton.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.sendButton.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.sendButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.sendButton.clipsToBounds = YES;
    
    
    self.channelList.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.channelList.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.channelList.layer.borderColor = [UIColor blackColor].CGColor;
    self.channelList.clipsToBounds = YES;

    
    NSMutableString *listText = nil;
    
    for(NSString *listId in self.listsToSendTo)
    {
        BPModelUserList *list = [[CommonAppDelegate channels] getChannel:listId];
        if(list==nil)
        {
            continue;
        }
        
        if(listText==nil)
        {
            listText=[[NSString stringWithString:list.name] mutableCopy];
        }
        else
        {
            [listText appendFormat:@", %@",list.name];
        }
        
        self.channelList.text = listText;
        self.channelList.hidden=NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
