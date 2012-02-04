//
//  StatsManager.m
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

#import "StatsManager.h"
#import "GameManager.h"

static const unsigned int POINTS_PAIRSOPENED = 15;
static const unsigned int POINTS_PAIRSMATCHED = 100;
static const unsigned int MULTIPLIER_UPGRADE = 1;

@interface StatsManager (PrivateMethods)
- (void) resetPerGameStats;
@end

@implementation StatsManager

#pragma mark - properties
@synthesize score = _score;
@synthesize multiplier = _multiplier;
@synthesize pairsOpened = _pairsOpened;
@synthesize pairsMatched = _pairsMatched;
@synthesize didLastGameHaveHighscore = _didLastGameHaveHighscore;

- (float) accuracy
{
    float result = 0.0f;
    if(0 < _pairsOpened)
    {
        result = ((float)_pairsMatched) / ((float)_pairsOpened);
    }
    return result;
}

- (int) accuracyPercent
{
    float result = floorf([self accuracy] * 100.0f);
    int intResult = (int)(result);
    return intResult;
}

#pragma mark - init / shutdown

- (id) init
{
    self = [super init];
    if(self)
    {
        _score = 0;
        _multiplier = 1;
        _pairsOpened = 0;
        _pairsMatched = 0;
        _highScore = 0;
        _didLastGameHaveHighscore = NO;
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark - private methods

- (void) resetPerGameStats
{
    _score = 0;
    _multiplier = 1;
    _pairsOpened = 0;
    _pairsMatched = 0;
    _didLastGameHaveHighscore = NO;
}


#pragma mark - public methods

- (void) reportPairMatched:(BOOL)hasMatched
{
    unsigned int newScore = 0;
    
    // track pairs opened
    ++_pairsOpened;
    
    // player gets one point for every pair they open
    newScore += POINTS_PAIRSOPENED;
    
    if(hasMatched)
    {
        ++_pairsMatched;
        newScore += (POINTS_PAIRSMATCHED * (1.0f + [self accuracy]));
    }
    
    // commit to total score
    _score += (newScore * _multiplier);
}

- (void) upgradeMultiplier
{
    _multiplier += MULTIPLIER_UPGRADE;
}

- (void) newGame
{
    // reset stats for new game
    [self resetPerGameStats];
}

- (void) gameEnded
{
    // commit new highscore
    if(_highScore < _score)
    {
        _highScore = _score;
        _didLastGameHaveHighscore = YES;
    }
    else
    {
        _didLastGameHaveHighscore = NO;
    }
}

- (void) restartGame
{
    [self resetPerGameStats];
}

- (void) resetHighscore
{
    _highScore = 0;
}

#pragma mark - Singleton
static StatsManager *singleton = nil;

+ (StatsManager*) getInstance
{
	@synchronized(self)
	{
		if (!singleton)
		{
			singleton = [[[StatsManager alloc] init] retain];
		}
	}
	return singleton;
}

+ (void) destroyInstance
{
	@synchronized(self)
	{
		[singleton release];
		singleton = nil;
	}
}


@end
