//
//  GameManager.h
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

#import <Foundation/Foundation.h>
#import "GameConfig.h"
#import "Nextpeer/NextpeerDelegate.h"
#import "Nextpeer/NPTournamentDelegate.h"

@class ImageLib;
@class Card;
@interface GameManager : NSObject<NextpeerDelegate,NPTournamentDelegate>
{
    // config
    GameConfig*     _curConfig;
    
    // game resources
    ImageLib*       _imageLib;
    NSMutableArray* _deck;
    
    // runtime variables
    NSMutableArray* _scratchDeck;
    NSMutableArray* _roundCards;
    NSTimeInterval _timeRemaining;
    unsigned int _numConsecutiveMatches;
    BOOL _shouldStartGame;
    BOOL _hasFinishedGame;
    BOOL _shouldExitGame;
    
    unsigned int _numAttacksReceived;
    unsigned int _numAttacksProcessed;
    NSString* _lastAttackerName;
    float _lastAttackAngle;
    
}
@property (nonatomic,retain) GameConfig* curConfig;
@property (nonatomic,retain) ImageLib* imageLib;
@property (nonatomic,retain) NSMutableArray* deck;
@property (nonatomic,retain) NSMutableArray* scratchDeck;
@property (nonatomic,retain) NSMutableArray* roundCards;
@property (nonatomic,readonly) NSTimeInterval timeRemaining;
@property (nonatomic,readonly) unsigned int numConsecutiveMatches;
@property (nonatomic,readonly) BOOL shouldStartGame;
@property (nonatomic,readonly) BOOL hasFinishedGame;
@property (nonatomic,readonly) BOOL shouldExitGame;
@property (nonatomic,retain) NSString* lastAttackerName;
@property (nonatomic,assign) float lastAttackAngle;
- (BOOL) hasBeenAttacked;
- (Card*) roundCardAtIndex:(unsigned int)index;
- (float) timePercentRemaining;
- (unsigned int) curGameMode;

// game flow
- (void) newGameWithConfig:(GameConfig*)config;
- (void) exitGame;
- (void) restartGame;
- (void) newRound;
- (void) exitRound;
- (void) update:(NSTimeInterval)elapsed;
- (void) exitRequested;
- (void) startRequested;

// game logic
- (BOOL) matchCards:(Card*)card1:(Card*)card2;
- (void) pushAttackToOtherPlayers;

// singleton
+ (GameManager*) getInstance;
+ (void) destroyInstance;



@end
