//
//  AppDelegate.h
//  registerlogin
//
//  Created by Nick Ambrose on 1/13/14.
//  Copyright (c) 2014 Buddy Platform. All rights reserved.
//

@class MainViewController;

#import <BuddySDK/Buddy.h>

#define CommonAppDelegate (AppDelegate*)[[UIApplication sharedApplication] delegate]

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,BPClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) UINavigationController *navController;
@property (nonatomic,strong) MainViewController *topController;
@property (nonatomic,assign) BOOL loginPresented;

-(void) storeUsername:(NSString*)userName;
-(NSString*) fetchUsername;
-(BOOL) isUsernameSet;

/* Store this in a more secure place than User Preferences in a real App */

-(void) storePassword:(NSString*)userName;
-(NSString*) fetchPassword;
-(BOOL) isPasswordSet;

-(void) storeUsername:(NSString *)userName andPassword:(NSString*)password;

-(void) authorizationNeedsUserLogin;

@end
