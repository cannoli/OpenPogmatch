//
//  StatsManager.h
//  pogmatch
//
//  Created by Shu Chiun Cheah on 1/29/12.
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


@interface StatsManager : NSObject
{
    // current game session
    unsigned int _score;
    unsigned int _multiplier;
    unsigned int _pairsOpened;
    unsigned int _pairsMatched;
    
    // global
    unsigned int _highScore;
    
    // informational
    BOOL _didLastGameHaveHighscore;
}
@property (nonatomic,readonly) unsigned int score;
@property (nonatomic,readonly) unsigned int multiplier;
@property (nonatomic,readonly) unsigned int pairsOpened;
@property (nonatomic,readonly) unsigned int pairsMatched;
@property (nonatomic,readonly) float accuracy;
@property (nonatomic,readonly) int accuracyPercent;
@property (nonatomic,readonly) BOOL didLastGameHaveHighscore;

- (void) reportPairMatched:(BOOL)hasMatched;
- (void) upgradeMultiplier;
- (void) newGame;
- (void) gameEnded;
- (void) restartGame;
- (void) resetHighscore;

// singleton
+ (StatsManager*) getInstance;
+ (void) destroyInstance;

@end
