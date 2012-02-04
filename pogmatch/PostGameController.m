//
//  PostGameController.m
//  pogmatch
//
//  Created by Shu Chiun Cheah on 1/30/12.
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

#import "PostGameController.h"
#import "StatsManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostGameController
@synthesize delegate = _delegate;

#pragma mark - init/shutdown
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _delegate = nil;
    }
    return self;
}

- (void)dealloc 
{
    [_delegate release];
    [_backScrim release];
    [_contentView release];
    [_scoreLabel release];
    [_pairsMatchedLabel release];
    [_pairsOpenedLabel release];
    [_accuracyLabel release];
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
    
    // init round corners
    [[_backScrim layer] setCornerRadius:3.0f];
    [[_backScrim layer] setMasksToBounds:YES];
    [[_backScrim layer] setBorderWidth:2.0f];
    [[_backScrim layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[_contentView layer] setCornerRadius:8.0f];
    [[_contentView layer] setMasksToBounds:YES];
    [[_contentView layer] setBorderWidth:5.0f];
    [[_contentView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (void)viewDidUnload
{
    [_delegate release];
    _delegate = nil;
    [_backScrim release];
    _backScrim = nil;
    [_contentView release];
    _contentView = nil;
    [_scoreLabel release];
    _scoreLabel = nil;
    [_pairsMatchedLabel release];
    _pairsMatchedLabel = nil;
    [_pairsOpenedLabel release];
    _pairsOpenedLabel = nil;
    [_accuracyLabel release];
    _accuracyLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - public methods

- (void) refreshLabelsWithStats
{
    [_scoreLabel setText:[NSString stringWithFormat:@"%d", [[StatsManager getInstance] score]]];
    [_pairsOpenedLabel setText:[NSString stringWithFormat:@"%d", [[StatsManager getInstance] pairsOpened]]];
    [_pairsMatchedLabel setText:[NSString stringWithFormat:@"%d", [[StatsManager getInstance] pairsMatched]]];
    [_accuracyLabel setText:[NSString stringWithFormat:@"%d%%", [[StatsManager getInstance] accuracyPercent]]];
}

#pragma mark - buttons

- (void) exitButtonPressed:(id)sender
{
    if(_delegate)
    {
        [_delegate dismissPostGameControllerExitGame:YES];
    }
}

- (void) restartButtonPressed:(id)sender
{
    if(_delegate)
    {
        [_delegate dismissPostGameControllerExitGame:NO];
    }
}
@end
