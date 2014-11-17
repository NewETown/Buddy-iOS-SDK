//
//  MainViewController.m
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import <BuddySDK/Buddy.h>

#import "UICheckboxTableItem.h"

#import "Constants.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "AddChannelViewController.h"
#import "ChannelViewController.h"
#import "SendMessageViewController.h"
#import "ViewMessagesViewController.h"

#import "ViewChannelListTable.h"
#import "ViewChannelListItem.h"
#import "ChannelList.h"

@interface MainViewController ()

-(void)doDownload;

@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) ViewChannelListTable *table;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _table =[[ViewChannelListTable alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addChannelButton.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.addChannelButton.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.addChannelButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.addChannelButton.clipsToBounds = YES;

    self.sendMessageButton.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.sendMessageButton.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.sendMessageButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.sendMessageButton.clipsToBounds = YES;
    
    self.viewMessagesButton.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.viewMessagesButton.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.viewMessagesButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.viewMessagesButton.clipsToBounds = YES;

    [[CommonAppDelegate navController] setNavigationBarHidden:NO];
    
    UIBarButtonItem *backButton =[[UIBarButtonItem alloc] initWithTitle:@"Logout"  style:UIBarButtonItemStylePlain target:self action:@selector(doLogout)];
    
    
    self.navigationItem.leftBarButtonItem = backButton;

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self  action:@selector(doDownload)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    if(Buddy.user==nil)
    {
        [CommonAppDelegate authorizationNeedsUserLogin];
        return;
    }
    [self doDownload];
}

- (void) tableView: (UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewChannelListItem *item = [self.table.table objectAtIndex:indexPath.row];
    BPUserList *list = [[CommonAppDelegate channels] getChannel:item.listID];
    
    ChannelViewController *vc = [[ChannelViewController alloc] initWithNibName:@"ChannelViewController" bundle:nil channel:list];
    [ [CommonAppDelegate navController] pushViewController:vc animated:YES];

}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChannelTableRow";
    
    ViewChannelListItem *item = [self.table.table objectAtIndex:indexPath.row];
    
    UITableViewCell *Cell = nil;

    Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(nil==Cell)
    {
        // Got to load one
        UINib *theCellNib = [UINib nibWithNibName:@"ChannelTableItemView" bundle:nil];
        [theCellNib instantiateWithOwner:self options:nil];
        Cell = [self tableCell];
    }

    UICheckboxTableItem *checked = (UICheckboxTableItem*)[Cell viewWithTag:1];
    checked.row = indexPath;
    
    UILabel *channelName = (UILabel*)[Cell viewWithTag:2];

    checked.checked =item.isChecked;
    
    BPUserList *list = [[CommonAppDelegate channels] getChannel:item.listID];
    
    if(list==nil)
    {
        channelName.text = @"Unknown(Error)";
    }
    else
    {
        channelName.text = list.name;
    }
    
    return Cell;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[CommonAppDelegate navController] setNavigationBarHidden:NO];

    [self doDownload];
    
}
- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.table itemCount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addChannel:(id)sender
{
    AddChannelViewController  *vc =[[AddChannelViewController alloc] initWithNibName:@"AddChannelViewController" bundle:nil];
    
    [ [CommonAppDelegate navController] pushViewController:vc animated:YES];
    
}

- (IBAction)boxChecked:(id)sender
{
    UICheckboxTableItem *box = (UICheckboxTableItem*)sender;
    
    ViewChannelListItem *item = [self.table.table objectAtIndex:box.row.row];
    if(box.checked==YES)
    {
        item.isChecked = YES;
    }
    else
    {
        item.isChecked = NO;
    }
    
}

- (void)doLogout
{
    [Buddy logoutUser:^(NSError *error)
     {
         NSLog(@"Logout Callback Called");
     }];
    
    [CommonAppDelegate authorizationNeedsUserLogin];
}

- (IBAction)sendMessage:(id)sender
{
    NSMutableArray *sendTo = [[NSMutableArray alloc] init];
    
    // This is cruddy, dont access it directly
    for(ViewChannelListItem *listItem in self.table.table)
    {
        if(listItem.isChecked==NO)
        {
            continue;
        }
        
        [sendTo addObject:listItem.listID];
    }
    
    if([sendTo count]==0)
    {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Error"
                                   message: @"Please select at least one list"
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alert show];
        return;
    }
    SendMessageViewController *vc = [[SendMessageViewController alloc] initWithNibName:@"SendMessageViewController" bundle:nil lists:sendTo];
    [ [CommonAppDelegate navController] pushViewController:vc animated:YES];
}

- (IBAction)viewMessages:(id)sender
{
    ViewMessagesViewController *vc = [[ViewMessagesViewController alloc] initWithNibName:@"ViewMessagesViewController" bundle:nil];
    vc.title = @"Messages";
    [ [CommonAppDelegate navController] pushViewController:vc animated:YES];
}

-(void)doDownload
{
    NSDictionary *parameters = @{@"readPermissions": @"App"};

    [Buddy GET:@"users/lists" parameters:parameters class:[BPPageResults class] callback:^(id obj,NSError *error)
    {
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
        [[CommonAppDelegate channels] clearChannels];
        
        [self.table clear];
        
        BPPageResults *searchResult = (BPPageResults*)obj;
        
        NSArray *searchItems = [searchResult convertPageResultsToType:[BPUserList class]];
        
        for(BPUserList* userList in searchItems)
        {
            [[CommonAppDelegate channels]  addChannel:userList];
            ViewChannelListItem *newItem = [[ViewChannelListItem alloc]init];
            newItem.listID =userList.id;
            newItem.isChecked=NO;
            [self.table addItem:newItem];
            
        }
        [self.channelTable reloadData];
    }];
}
@end
