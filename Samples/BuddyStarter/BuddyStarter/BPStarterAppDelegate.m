//
//  BPStarterAppDelegate.m
//
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

#import "BPStarterAppDelegate.h"
#import "BPStarterViewController.h"
#import "BPStarterLoginViewController.h"
#import <BuddySDK/Buddy.h>

#import <UIKit/UIKit.h>


@interface BPStarterAppDelegate ()

    @property (atomic) UIViewController* loginViewController;

@end

@implementation BPStarterAppDelegate

@synthesize loginViewController;

BOOL loginPresented;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize the Buddy SDK
    // This initialization does NOT cause a network call, but will be processed
    // upon the first call to a Buddy API.

    // Go to http://buddyplatform.com to get an app ID and app key.
    [Buddy init:\@"Your App ID" appKey:\@"Your App Key"];
    
    self.window = [[UIWindow alloc] initWithFrame:
                   [[UIScreen mainScreen] bounds]];
 
    self.window.rootViewController = [[BPStarterViewController alloc]
                                      initWithNibName:@"BPStarterViewController" bundle:nil];
    [self.window makeKeyAndVisible];
    
    return YES;
}

//
// Buddy SDK Auth Helper
//
// The following selector will be called automatically by the Buddy SDK
// when a method requiring user-level authenication fails due to insufficient
// permissions.  In this selector, you should display your login UI.
//
-(void)authorizationNeedsUserLogin
{
    
    if (self.loginViewController == nil) {
        
        self.loginViewController = [[BPStarterLoginViewController alloc]init];
        
    }
    else if (self.loginViewController.presentingViewController != nil) {
        return;
    }
    UIViewController* rootController = (UINavigationController*) self.window.rootViewController;

    [rootController presentViewController:self.loginViewController animated:YES completion:^{
        
    }];
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
