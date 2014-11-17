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

#import "SearchUsersViewController.h"
#import "UserDetailViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface SearchUsersViewController ()

@property (nonatomic,strong) MBProgressHUD *HUD;

-(void) loadAllUsers;
- (void) putAllUsers:(NSMutableArray *)users;
-(RESTCallback) getAllUsersCallback;

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
    
    [self setTitle:@"Search Users"];
    

   
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
    [Buddy GET:@"users" parameters:nil class:[BPPageResults class] callback:[self getAllUsersCallback]];
}

-(RESTCallback) getAllUsersCallback
{
    SearchUsersViewController * __weak weakSelf = self;
    
    return ^(id obj,NSError *error)
    {
        [weakSelf.HUD hide:TRUE afterDelay:0.1];
        weakSelf.HUD = nil;
        
        if(error!=nil)
        {
            NSLog(@"getAllUsersCallback - error: %@", [error description]);
            return;
        }
        
        BPPageResults *searchResult = (BPPageResults*)obj;
        
        NSArray *searchUsers = [searchResult convertPageResultsToType:[BPUser class]];
        NSLog(@"getAllUsersCallback - success Called");
        [self putAllUsers:[searchUsers mutableCopy]];
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
    
    if (aUser.firstName || aUser.lastName) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@ %@)",
                               aUser.userName,
                               aUser.firstName ? aUser.firstName :  @"",
                               aUser.lastName ? aUser.lastName : @""];
    }
    else {
         cell.textLabel.text = [NSString stringWithFormat:@"%@ ", aUser.userName];
    
    }
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


@end
