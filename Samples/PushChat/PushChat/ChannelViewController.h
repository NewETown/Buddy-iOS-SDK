//
//  ChannelViewController.h
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BPUserList;

@interface ChannelViewController : UIViewController

@property (nonatomic,weak) IBOutlet UILabel *channelName;
@property (nonatomic,weak) IBOutlet UIButton *joinBut;
@property (nonatomic,weak) IBOutlet UIButton *leaveBut;
@property (nonatomic,weak) IBOutlet UIButton *deleteBut;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil channel:(BPUserList*)channel;

-(IBAction)join:(id)sender;
-(IBAction)leave:(id)sender;
-(IBAction)deleteList:(id)sender;
@end
