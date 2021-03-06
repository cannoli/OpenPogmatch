//
//  AppDelegate.m
//  pogmatch
//
//  Created by Shu Chiun Cheah on 1/25/12.
//  Copyright (c) 2012 GeoloPigs Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
//  NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "AppDelegate.h"
#import "MainMenu.h"
#import "GameManager.h"
#import "StatsManager.h"
#import "PogAppEventHandler.h"

@interface AppDelegate (PrivateMethods)
- (void) appInit;
- (void) appShutdown;
- (void) setupNavigationController;
- (void) teardownNavigationController;
- (void) setupBackground;
- (void) teardownBackground;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize navController = _navController;
@synthesize rootController = _rootController;
@synthesize backgroundImage = _backgroundImage;

#pragma mark - app methods
- (void) appInit
{
    [GameManager getInstance];
    [StatsManager getInstance];
}

- (void) appShutdown
{
    [StatsManager destroyInstance];
    [GameManager destroyInstance];
}

- (void) setupNavigationController
{
    // create the root view controller first
    self.rootController = [[[MainMenu alloc] initWithNibName:@"MainMenu" bundle:nil] autorelease];
    
    // add it to our navigation controller
    self.navController = [[[UINavigationController alloc] initWithRootViewController:[self rootController]] autorelease];
    [self.navController setNavigationBarHidden:YES];
    [self.window addSubview:[[self navController]view]];
}

- (void) teardownNavigationController
{
    [self.navController.view removeFromSuperview];
    self.rootController = nil;
    self.navController = nil;
}

- (void) setupBackground
{
    self.backgroundImage = [[[UIImageView alloc] initWithFrame:self.window.frame] autorelease];
    self.backgroundImage.image = [UIImage imageNamed:@"Default@2x.png"];
    [self.window addSubview:[self backgroundImage]];
    self.window.backgroundColor = [AppDelegate backgroundColor];
}

- (void) teardownBackground
{
    self.backgroundImage = nil;
}

#pragma mark - UIApplicationDelegate
- (void)dealloc
{
    [self appShutdown];
    [self teardownNavigationController];
    [self teardownBackground];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    // create window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self setupBackground];
    [self.window makeKeyAndVisible];
    
    // setup navigation controller
    [self setupNavigationController];
    
    [self appInit];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // inform any top controller that needs to handle this
    UIViewController* topController = [self.navController topViewController];
    if([topController conformsToProtocol:@protocol(PogAppEventHandler)])
    {
        UIViewController<PogAppEventHandler>* target = (UIViewController<PogAppEventHandler>*)topController;
        [target appWillResignActive];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // inform any top controller that needs to handle this
    UIViewController* topController = [self.navController topViewController];
    if([topController conformsToProtocol:@protocol(PogAppEventHandler)])
    {
        UIViewController<PogAppEventHandler>* target = (UIViewController<PogAppEventHandler>*)topController;
        [target appDidBecomeActive];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - helper functions

+ (UIColor*) backgroundColor
{
    return [UIColor colorWithRed:0.51f green:0.79f blue:0.78f alpha:1.0f];
}

@end
