//
//  GameViewController.h
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

#import <UIKit/UIKit.h>
#import "PostGameController.h"
#import "PogAppEventHandler.h"

@class GameConfig;
@class PogUIProgressBar;
@interface GameViewController : UIViewController<PostGameControllerDelegate,PogAppEventHandler>
{
    // subviews
    IBOutlet UIView *_gameView;
    IBOutlet UIView *_hudView;
    IBOutlet UILabel *_scoreLabel;
    IBOutlet PogUIProgressBar *_timeBar;
    PostGameController* _postGameViewController;
    IBOutlet UILabel *_bannerLabel;
    IBOutlet UILabel *_subBannerLabel;
    
    // per frame processing
    NSTimer*	_gameLoopTimer;
	NSTimeInterval _prevTick;
    
    // for pausing _gameLoopTimer when app is not active
    NSDate* _savedTime;
    NSDate* _savedFiringDate;
    
    // game state
    unsigned int _gameState;
    NSMutableArray* _cardViews;
    NSMutableArray* _activeCardViews;
    NSMutableArray* _selectedCards;
    
    // trigger variables
    BOOL _triggerRoundCompleted;
    NSTimeInterval _delayTimer;

    // configs
    GameConfig* _gameConfig;
}
@property (nonatomic,retain) GameConfig* gameConfig;
@property (nonatomic,retain) PostGameController* postGameViewController;

- (IBAction) exitButtonPressed:(id)sender;
@end
