//
//  MainMenu.m
//  pogmatch
//
//  Created by Shu Chiun Cheah on 1/25/12.
//  Copyright (c) 2012 GeoloPigs, Inc.
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

#import "MainMenu.h"
#import "AppDelegate.h"
#import "GameViewController.h"
#import "UINavigationController+Pog.h"
#import "GameConfig.h"
#import "Nextpeer/Nextpeer.h"
#import <QuartzCore/QuartzCore.h>


@interface MainMenu (PrivateMethods)
+ (GameConfig*) singleplayerGameConfig;
+ (GameConfig*) multiplayerGameConfig;
- (void) startGameWithConfig:(GameConfig*)config;
@end

@implementation MainMenu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
    }
    return self;
}

- (void)dealloc 
{
    [_loadingView removeFromSuperview];
    [_loadingView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create a fullscreen loading view and add it on top of all subviews
    _loadingView = [[UIView alloc] initWithFrame:[self.view bounds]];
    [_loadingView setBackgroundColor:[UIColor blackColor]];
    [_loadingView setAlpha:0.8f];
    [_loadingView setHidden:YES];
    [self.view addSubview:_loadingView];
}

- (void)viewDidUnload
{
    [_loadingView removeFromSuperview];
    [_loadingView release];
    _loadingView = nil;
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_loadingView setHidden:YES];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - game configs
+ (GameConfig*) singleplayerGameConfig
{
    GameConfig* newConfig = [[[GameConfig alloc] initWithImageLibName:@"CardImages" numRows:5 numColumns:4] autorelease];
    newConfig.gameDuration = 90.0f;
    newConfig.gameMode = GAMEMODE_SINGLEPLAYER;
    return newConfig;
}

+ (GameConfig*) multiplayerGameConfig
{
    GameConfig* newConfig = [[[GameConfig alloc] initWithImageLibName:@"CardImages" numRows:5 numColumns:4] autorelease];
    newConfig.gameDuration = 120.0f;            // <-- 2 minutes
    newConfig.gameMode = GAMEMODE_MULTIPLAYER;  // <-- multiplayer
    return newConfig;    
}

#pragma mark - buttons
- (void) startGameWithConfig:(GameConfig *)config
{
    // fade in the loading screen to hide load time
    [_loadingView setHidden:NO];
    [_loadingView setAlpha:0.0f];
    [UIView animateWithDuration:0.2f 
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^{
                         [_loadingView setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){
                         GameViewController* newController = [[GameViewController alloc] init];
                         newController.gameConfig = config;
                         AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                         [delegate.navController pushFadeInViewController:newController animated:YES];
                         [newController release];
                     }];    
}

- (void) playButtonPressed:(id)sender
{
    [self startGameWithConfig:[MainMenu singleplayerGameConfig]];
}

- (IBAction)multiplayerButtonPressed:(id)sender 
{
    [Nextpeer launchDashboard];
    [self startGameWithConfig:[MainMenu multiplayerGameConfig]]; // <-- start game in multiplayer mode
}


@end
