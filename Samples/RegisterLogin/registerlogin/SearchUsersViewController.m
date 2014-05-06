//
//  SearchUsersViewController.m
//  registerlogin
//
//  Created by devmania on 3/28/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>

#import <BuddySDK/Buddy.h>
#import <BuddySDK/BPUserCollection.h>
#import <BuddySDK/BPUser.h>

#import "SearchUsersViewController.h"
#import "UserDetailViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface SearchUsersViewController ()

@property (nonatomic,strong) MBProgressHUD *HUD;

-(void) loadAllUsers;
- (void) putAllUsers:(NSMutableArray *)users;
-(BuddyCollectionCallback) getAllUsersCallback;

@end

@implementation SearchUsersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
        _allUsersList = [NSMutableArray array];
        _filteredUserList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [UIButton buttonWithType:UIButtonTypeSystem];
    
    self.searchBut.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.searchBut.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.searchBut.layer.borderColor = [UIColor blackColor].CGColor;
    self.searchBut.clipsToBounds = YES;
    
    self.backBut.layer.cornerRadius = DEFAULT_BUT_CORNER_RAD;
    self.backBut.layer.borderWidth = DEFAULT_BUT_BORDER_WIDTH;
    self.backBut.layer.borderColor = [UIColor blackColor].CGColor;
    self.backBut.clipsToBounds = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText= @"Loading...";
    self.HUD.dimBackground = YES;
    self.HUD.delegate=self;
    
    [self loadAllUsers];
}

-(void) loadAllUsers
{
    [[Buddy users] getAll:[self getAllUsersCallback]];
}

-(BuddyCollectionCallback) getAllUsersCallback
{
    SearchUsersViewController * __weak weakSelf = self;
    
    return ^(NSArray *buddyObjects, NSError *error)
    {
        [weakSelf.HUD hide:TRUE afterDelay:0.1];
        weakSelf.HUD = nil;
        
        if(error!=nil)
        {
            NSLog(@"getAllUsersCallback - error: %@", [error description]);
            return;
        }
        
        NSLog(@"getAllUsersCallback - success Called");
        [self putAllUsers:[buddyObjects mutableCopy]];
        [self.tableView reloadData];
        
    };
}

- (void) putAllUsers:(NSMutableArray *)users
{
    [self.allUsersList removeAllObjects];
    self.allUsersList = users;
    self.filteredUserList = [self.allUsersList mutableCopy];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredUserList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    BPUser *aUser = [self.filteredUserList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", aUser.firstName, aUser.lastName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BPUser *aUser = [self.filteredUserList objectAtIndex:indexPath.row];
    UserDetailViewController *subVC = [[UserDetailViewController alloc]
                                        initWithNibName:@"UserDetailViewController" bundle:nil];
    subVC.user = aUser;
    [ [CommonAppDelegate navController] pushViewController:subVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSearch:(id)sender
{
    [self.filteredUserList removeAllObjects];
    
    NSString *keyword = self.searchField.text;
    
    if ([keyword length]==0)
    {
        self.filteredUserList = [self.allUsersList mutableCopy];
    }
    else
    {
        for(BPUser *user in self.allUsersList)
        {
            if ([user.firstName rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [self.filteredUserList addObject:user];
                continue;
            }
            else if ([user.lastName rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [self.filteredUserList addObject:user];
                continue;
            }
        }
    }
    
    [self.tableView reloadData];
}

- (IBAction)doBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
