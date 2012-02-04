//
//  GameViewController.m
//  pogmatch
//
//  Created by Shu Chiun Cheah on 1/26/12.
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

#import "GameViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+Pog.h"
#import "GameManager.h"
#import "StatsManager.h"
#import "GameConfig.h"
#import "Card.h"
#import "CardView.h"
#import "PogUIProgressBar.h"
#import "PostGameController.h"

// constants
static const CGFloat GAMELOOP_INTERVAL_SECS = 1.0f / 30.0f;
static const CGFloat GAMELOOP_INTERVAL_MAX = 1.0f / 15.0f;
static const CGFloat CARDPLACEMENT_SPACING_X = 10.0f;
static const CGFloat CARDPLACEMENT_SPACING_Y = 10.0f;
static const CGFloat POSTROUND_DELAY = 0.5f;
static const CGFloat POSTGAME_DELAY = 1.0f;

enum GameStates
{
    GAMESTATE_INIT = 0,
    GAMESTATE_INPROGRESS,
    GAMESTATE_POSTROUND,
    GAMESTATE_POSTGAME,     
    GAMESTATE_EXIT,
    
    GAMESTATE_NUM,
    GAMESTATE_INVALID
};


@interface GameViewController (PrivateMethods)
- (void) initGameLoop;
- (void) shutdownGameLoop;
- (NSTimeInterval) advanceTimer;
- (void) gameLoop;
- (void) backToMainMenu;
                                   
- (void) setupGameViewForNewRound;
- (void) gameViewExitRound;
- (void) selectCard:(id)sender;
- (void) refreshTimeBar;
- (void) refreshScoreLabel;
- (void) showPostGame;
- (void) showBanner:(NSString*)text;
- (void) showSubBanner:(NSString*)text;
@end

@implementation GameViewController
@synthesize gameConfig = _gameConfig;
@synthesize postGameViewController = _postGameViewController;

#pragma mark - init / shutdown

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        _gameConfig = nil;
        _gameState = GAMESTATE_INVALID;
        _postGameViewController = nil;
        _triggerRoundCompleted = NO;
        _delayTimer = 0.0;
    }
    return self;
}

- (void) dealloc
{
    [self shutdownGameLoop];
    [_postGameViewController release];
    [_gameConfig release];
    [_selectedCards release];
    [_activeCardViews release];
    [_cardViews release];
    [_gameView release];
    [_hudView release];
    [_scoreLabel release];
    [_timeBar release];
    [_bannerLabel release];
    [_subBannerLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _cardViews = [[NSMutableArray array] retain];
    _activeCardViews = [[NSMutableArray array] retain];
    _selectedCards = [[NSMutableArray array] retain];

    [self initGameLoop];
    
    // init values of all dynamic UI
    [self refreshScoreLabel];
    [self refreshTimeBar];
    [_bannerLabel setHidden:YES];
    [_subBannerLabel setHidden:YES];
}

- (void)viewDidUnload
{
    [self shutdownGameLoop];
    if(_postGameViewController)
    {
        [_postGameViewController.view removeFromSuperview];
    }
    [_postGameViewController release];
    _postGameViewController = nil;
    [_gameConfig release];
    _gameConfig = nil;
    [_activeCardViews release];
    _activeCardViews = nil;
    [_cardViews release];
    _cardViews = nil;
    [_gameView release];
    _gameView = nil;
    [_hudView release];
    _hudView = nil;
    [_scoreLabel release];
    _scoreLabel = nil;
    [_timeBar release];
    _timeBar = nil;
    [_bannerLabel release];
    _bannerLabel = nil;
    [_subBannerLabel release];
    _subBannerLabel = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - game loop

- (void) initGameLoop
{
    // start a new game
    [[GameManager getInstance] newGameWithConfig:[self gameConfig]];
    [[StatsManager getInstance] newGame];
    
    // go to the init-state
    _gameState = GAMESTATE_INIT;
    
    // reset trigger variables
    _triggerRoundCompleted = NO;
    _delayTimer = 0.0;
    
    // create an NSTimer to perform per-frame processing
	_gameLoopTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval) GAMELOOP_INTERVAL_SECS
                                                     target:self 
                                                   selector:@selector(gameLoop) 
                                                   userInfo:nil 
                                                    repeats:YES];
	_prevTick = [NSDate timeIntervalSinceReferenceDate];	
}

- (void) shutdownGameLoop
{
    // kill our NSTimer
    [_savedTime release];
    _savedTime = nil;
    [_savedFiringDate release];
    _savedFiringDate = nil;
	[_gameLoopTimer invalidate];
    
    // exit the game
    [[GameManager getInstance] exitGame];
}

- (NSTimeInterval) advanceTimer
{
	NSTimeInterval curTick = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval elapsed = curTick - _prevTick;
	if(elapsed < GAMELOOP_INTERVAL_SECS)
	{
		elapsed = GAMELOOP_INTERVAL_SECS;
	}
	else if(elapsed > GAMELOOP_INTERVAL_MAX)
	{
        // when framerate is very low, clamp the elapsed time so that the game doesn't
        // get hit with unreasonably large time-step
		elapsed = GAMELOOP_INTERVAL_MAX;
	}
	_prevTick = curTick;	
	return elapsed;
}

// this is where the game updates happen
- (void) gameLoop
{
    NSTimeInterval elapsed = [self advanceTimer];
    
    switch(_gameState)
    {
        case GAMESTATE_POSTGAME:
            [self gameViewExitRound];
            [[GameManager getInstance] exitRound];
            [[GameManager getInstance] restartGame];
            [[StatsManager  getInstance] restartGame];
            _gameState = GAMESTATE_INIT;
            break;
            
        case GAMESTATE_INIT:
            if([[GameManager getInstance] shouldStartGame])
            {
                // start a new round
                [[GameManager getInstance] newRound];
                [self setupGameViewForNewRound];
                [self refreshTimeBar];
                _gameState = GAMESTATE_INPROGRESS;
                [self refreshScoreLabel];
            }
            else if([[GameManager getInstance] shouldExitGame])
            {
                _gameState = GAMESTATE_EXIT;
            }
            break;
            
        case GAMESTATE_INPROGRESS:
            if([[GameManager getInstance] shouldExitGame])
            {
                _gameState = GAMESTATE_EXIT;
            }
            else
            {
                [[GameManager getInstance] update:elapsed];
                [self refreshTimeBar];
                if(![[GameManager getInstance] hasFinishedGame])
                {
                    if(_triggerRoundCompleted)
                    {
                        _gameState = GAMESTATE_POSTROUND;
                        _triggerRoundCompleted = NO;
                        _delayTimer = POSTROUND_DELAY;
                        
                        // upgrade multiplier for next round
                        [[StatsManager getInstance] upgradeMultiplier];
                        
                        // show banner
                        [self showBanner:@"Multiplier Up"];
                        [self showSubBanner:[NSString stringWithFormat:@"x%d", [[StatsManager getInstance] multiplier]]];
                    }
                }
                else
                {
                    // time is up
                    
                    // tally up stats
                    [[StatsManager getInstance] gameEnded];

                    // in all other modes, show banner and post-game UI
                    [self showBanner:@"Time Up"];
                    [self showPostGame];
                    
                    _gameState = GAMESTATE_POSTGAME;
                }
            }            
            break;
            
        case GAMESTATE_POSTROUND:
            if(0.0f < _delayTimer)
            {
                _delayTimer -= elapsed;
            }
            else
            {
                // wrap up this round
                [self gameViewExitRound];
                [[GameManager getInstance] exitRound];
                
                _gameState = GAMESTATE_INIT;
            }
            break;
            
        case GAMESTATE_EXIT:
            [self gameViewExitRound];
            [[GameManager getInstance] exitRound];
            [[GameManager getInstance] exitGame];
            [self shutdownGameLoop];
            [self backToMainMenu];
            break;
    }
}

- (void) backToMainMenu
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate.navController popFadeOutViewControllerAnimated:YES];
}

- (void) selectCard:(id)sender
{
    CardView* senderCardView = (CardView*) sender;

    if(![_selectedCards containsObject:senderCardView])
    {
        // add it if card not yet selected
        [_selectedCards addObject:senderCardView];
        [senderCardView setState:CARD_STATE_SELECTED];
    }
    
    // if two cards selected, ask GameManager to process them
    if(1 < [_selectedCards count])
    {
        CardView* card1 = [_selectedCards objectAtIndex:0];
        CardView* card2 = [_selectedCards objectAtIndex:1];
        BOOL result = [[GameManager getInstance] matchCards:[card1 card] :[card2 card]];
        if(result)
        {
            // matched, hide and remove them
            [card1 setState:CARD_STATE_MATCHED];
            [card2 setState:CARD_STATE_MATCHED];
            [_activeCardViews removeObject:card1];
            [_activeCardViews removeObject:card2];
            
            // if this was the last pair of cards, we are done with this round
            if(0 == [_activeCardViews count])
            {
                _triggerRoundCompleted = YES;
            }
            else if(1 < [[GameManager getInstance] numConsecutiveMatches])
            {
                // upgrade multiplier for next round
                [[StatsManager getInstance] upgradeMultiplier];
                
                // show banner
                [self showBanner:@"Multiplier Up"];
                [self showSubBanner:[NSString stringWithFormat:@"x%d", [[StatsManager getInstance] multiplier]]];
            }
        }
        else
        {
            // not matched, cover them
            [card1 setState:CARD_STATE_ACTIVE];
            [card2 setState:CARD_STATE_ACTIVE];
        }
        
        // refresh UI
        [self refreshScoreLabel];
        
        // clear the selected array
        [_selectedCards removeAllObjects];
    }
}

#pragma mark - graphics

// initializes the subview in which the game takes place
- (void) setupGameViewForNewRound
{
    unsigned int rows = [[[GameManager getInstance] curConfig] numRows];
    unsigned int cols = [[[GameManager getInstance] curConfig] numColumns];
    
    CGRect myFrame = [_gameView bounds];
    CGFloat cardWidth = floorf((myFrame.size.width - ((cols+1) * CARDPLACEMENT_SPACING_X)) / cols);
    CGFloat cardHeight = cardWidth;
    
    for(unsigned int curRow = 0; curRow < rows; ++curRow)
    {
        for(unsigned int curCol = 0; curCol < cols; ++curCol)
        {
            unsigned int index = (curRow * cols) + curCol;
            Card* curGameCard = [[GameManager getInstance] roundCardAtIndex:index];
            CGFloat posX = CARDPLACEMENT_SPACING_X + (curCol * (CARDPLACEMENT_SPACING_X + cardWidth));
            CGFloat posY = CARDPLACEMENT_SPACING_Y + (curRow * (CARDPLACEMENT_SPACING_Y + cardHeight));
            CGRect cardFrame = CGRectMake(posX, posY, cardWidth, cardHeight);
            
            CardView* newView = [[CardView alloc] initWithFrame:cardFrame forCard:curGameCard];
            [newView addTarget:self action:@selector(selectCard:) forControlEvents:UIControlEventTouchUpInside];
            [_cardViews addObject:newView];
            [_activeCardViews addObject:newView];
            [_gameView addSubview:newView];
            [newView release];
        }
    }
    [_gameView setNeedsDisplay];
}

- (void) gameViewExitRound
{
    [_selectedCards removeAllObjects];
    [_activeCardViews removeAllObjects];
    for(CardView* cur in _cardViews)
    {
        [cur removeTarget:self action:@selector(selectCard:) forControlEvents:UIControlEventTouchUpInside];
        [cur removeFromSuperview];
    }
    [_cardViews removeAllObjects];
}

- (void) refreshTimeBar
{
    [_timeBar setProgressPercent:[[GameManager getInstance] timePercentRemaining]];
    [_timeBar setNeedsDisplay];
}

- (void) refreshScoreLabel
{
    [_scoreLabel setText:[NSString stringWithFormat:@"%d", [[StatsManager getInstance] score]]];
    [_scoreLabel setNeedsDisplay];
}

- (void) showPostGame
{
    PostGameController* newController = [[PostGameController alloc] initWithNibName:@"PostGameController" bundle:nil];
    CGSize mySize = self.view.bounds.size;
    CGSize postSize = newController.view.bounds.size;
    CGRect newFrame = CGRectMake(0.5f * (mySize.width - postSize.width), 
                                 0.5f * (mySize.height - postSize.height), 
                                 postSize.width, 
                                 postSize.height);
    newController.view.frame = newFrame;
    newController.delegate = self;
    
    // update labels with stats
    [newController refreshLabelsWithStats];    
    
    self.postGameViewController = newController;
    [self.view addSubview:[newController view]];
    [newController release];
    
    // fade it in
    self.postGameViewController.view.alpha = 0.0f;
    [UIView animateWithDuration:0.2f 
                          delay:POSTGAME_DELAY 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^{
                         [self.postGameViewController.view setAlpha:1.0f];
                     }
                     completion:NULL];
}

- (void) showBanner:(NSString *)text
{
    [_bannerLabel setText:text];
    [_bannerLabel setHidden:NO];
    [_bannerLabel setAlpha:0.0f];
    [UIView animateWithDuration:0.2f 
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [_bannerLabel setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.2f 
                                               delay:1.0f 
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              [_bannerLabel setAlpha:0.0f];
                                          }
                                          completion:^(BOOL finished){
                                              [_bannerLabel setHidden:YES];
                                          }];    
                     }];    
}

- (void) showSubBanner:(NSString *)text
{
    [_subBannerLabel setText:text];
    [_subBannerLabel setHidden:NO];
    [_subBannerLabel setAlpha:0.0f];
    [UIView animateWithDuration:0.2f 
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [_subBannerLabel setAlpha:1.0f];
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.2f 
                                               delay:1.0f 
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              [_subBannerLabel setAlpha:0.0f];
                                          }
                                          completion:^(BOOL finished){
                                              [_subBannerLabel setHidden:YES];
                                          }];    
                     }];    

}

#pragma mark - buttons

- (void) exitButtonPressed:(id)sender
{
    [[GameManager getInstance] exitRequested];
}


#pragma mark - PostGameControllerDelegate

- (void) dismissPostGameControllerExitGame:(BOOL)shouldExitGame
{
    if(GAMESTATE_INIT == _gameState)
    {
        if([self postGameViewController])
        {
            [self.postGameViewController.view removeFromSuperview];
            self.postGameViewController = nil;
        }
        
        if(shouldExitGame)
        {
            [[GameManager getInstance] exitRequested];
        }
        else
        {
            [[GameManager getInstance] startRequested];
        }
    }
}

#pragma mark - PogAppEventHandler
- (void) appWillResignActive
{
    // pause gameLoopTimer
    if([_gameLoopTimer isValid])
    {
        _savedTime = [[NSDate dateWithTimeIntervalSinceNow:0] retain];
        _savedFiringDate = [[_gameLoopTimer fireDate] retain];
        [_gameLoopTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void) appDidBecomeActive
{
    // restore gameLoopTimer
    if([_gameLoopTimer isValid])
    {
        // fast-forward timer to now
        NSTimeInterval timeSinceResignActive = -1.0 * [_savedTime timeIntervalSinceNow];
        [_gameLoopTimer setFireDate:[_savedFiringDate initWithTimeInterval:timeSinceResignActive sinceDate:_savedFiringDate]];
        [_savedTime release];
        _savedTime = nil;
        [_savedFiringDate release];
        _savedFiringDate = nil;
    }
}

@end
