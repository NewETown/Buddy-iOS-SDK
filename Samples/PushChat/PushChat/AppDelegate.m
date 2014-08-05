//
//  AppDelegate.m
//  PushChat
//
//  Created by Nick Ambrose on 5/30/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import "iToast.h"

#import "AppDelegate.h"
#import "Constants.h"

#import "MainViewController.h"
#import "LoginViewController.h"
#import "ReceivedMessageTable.h"
#import "ReceivedMessage.h"

#import "ChannelList.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.loginPresented=FALSE;
    
    MainViewController *mainVC = [[MainViewController alloc]
                                  initWithNibName:@"MainViewController" bundle:nil];
    
    mainVC.title = @"Channels";
    
    self.topController =mainVC;
    
    self.navController=[[UINavigationController alloc] initWithRootViewController:self.topController];
    
    [self.navController setNavigationBarHidden:TRUE];
    self.window.rootViewController=self.navController;
    
    
    [self.window makeKeyAndVisible];
    
    [Buddy init: APP_ID appKey: APP_KEY];
    
    
    _channels =[[ChannelList alloc] init];
    _receivedMessages = [ReceivedMessageTable new];
    return YES;
}

-(void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error  {
    NSLog(@"%@", error);
}
-(void) application:(UIApplication*) application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", deviceToken);
}

-(void) application:(UIApplication*) application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    ReceivedMessage *message = [[CommonAppDelegate receivedMessages] addMessageFromDict:userInfo];
    [[iToast makeText:[NSString stringWithFormat:@"%@:%@",message.channel, message.message]] show];    
}

/* UserName */

-(void) storeUsername:(NSString*)userName;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:userName forKey:USERNAME_PREF_KEY];
    [prefs synchronize];
}
-(NSString*) fetchUsername
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    return [prefs stringForKey:USERNAME_PREF_KEY];
}
-(BOOL) isUsernameSet
{
    NSString *userName = [self fetchUsername];
    if(userName==nil)
    {
        return NO;
    }
    if([userName length]==0)
    {
        return NO;
    }
    return YES;
}

/* Password - Store this somewhere more secure in a real App */

-(void) storePassword:(NSString*)userName;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:userName forKey:PASSWORD_PREF_KEY];
    [prefs synchronize];
}
-(NSString*) fetchPassword
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    return [prefs stringForKey:PASSWORD_PREF_KEY];
}
-(BOOL) isPasswordSet
{
    NSString *password = [self fetchPassword];
    if(password==nil)
    {
        return NO;
    }
    if([password length]==0)
    {
        return NO;
    }
    return YES;
}

-(void)authorizationNeedsUserLogin
{
    NSLog(@"auth Failed delegate called");
    
    if(self.loginPresented==YES)
    {
        return;
    }
    self.loginPresented=YES;
    LoginViewController *loginVC = [[LoginViewController alloc]
                                    initWithNibName:@"LoginViewController" bundle:nil];
    
    // Get the "topmost" VC (may need to be careful here if that VC has already presented a VC?
    [self.navController.topViewController presentViewController:loginVC animated:NO completion:nil];
    
}
-(void) storeUsername:(NSString *)userName andPassword:(NSString*)password
{
    [self storeUsername:userName];
    [self storePassword:password];
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
