//
//  GameManager.m
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

#import "GameManager.h"
#import "StatsManager.h"
#import "GameConfig.h"
#import "ImageLib.h"
#import "Card.h"
#import "CardView.h"
#import "Nextpeer/Nextpeer.h"


static const float TIMEBOOST_PER_MATCH = 2.0f;  // seconds
static const float SHAKERANGE_INCR = M_PI_2 / 6.0f;
static const float SHAKERANGE_MAX = M_PI_2;

@interface GameManager (PrivateMethods)
- (void) initDeck;
- (void) resetAttackStates;
@end

@implementation GameManager

#pragma mark - properties
@synthesize curConfig = _curConfig;
@synthesize imageLib = _imageLib;
@synthesize deck = _deck;
@synthesize scratchDeck = _scratchDeck;
@synthesize roundCards = _roundCards;
@synthesize timeRemaining = _timeRemaining;
@synthesize numConsecutiveMatches = _numConsecutiveMatches;
@synthesize shouldStartGame = _shouldStartGame;
@synthesize hasFinishedGame = _hasFinishedGame;
@synthesize shouldExitGame = _shouldExitGame;
@synthesize lastAttackerName = _lastAttackerName;
@synthesize lastAttackAngle = _lastAttackAngle;

- (Card*) roundCardAtIndex:(unsigned int)index
{
    Card* result = nil;
    if(index < [_roundCards count])
    {
        result = [_roundCards objectAtIndex:index];
    }
    return result;
}

- (float) timePercentRemaining
{
    return ((_timeRemaining / [_curConfig gameDuration]) * 100.0f);
}

- (unsigned int) curGameMode
{
    unsigned int result = GAMEMODE_SINGLEPLAYER;
    if(_curConfig)
    {
        result = [_curConfig gameMode];
    }
    return result;
}

- (BOOL) hasBeenAttacked
{
    BOOL result = NO;
    if(_numAttacksProcessed < _numAttacksReceived)
    {
        result = YES;
        _numAttacksProcessed = _numAttacksReceived;
    }
    return result;
}

#pragma mark - init / shutdown

- (id) init
{
    self = [super init];
    if(self)
    {
        _curConfig = nil;
        _imageLib = nil;
        _deck = nil;
        _scratchDeck = nil;
        _roundCards = nil;
        _timeRemaining = 0.0f;
        _numConsecutiveMatches = 0;
        _shouldStartGame = NO;
        _hasFinishedGame = NO;
        _shouldExitGame = NO;
    }
    return self;
}

- (void) dealloc
{
    [_roundCards release];
    [_scratchDeck release];
    [_deck release];
    [_imageLib release];
    [_curConfig release];
    [super dealloc];
}

#pragma mark - internals

// initializes deck with images from the loaded image lib
- (void) initDeck
{
    // create deck for this game session
    _deck = [[NSMutableArray arrayWithCapacity:[[[self imageLib] images] count]] retain];
    unsigned int index = 0;
    for(NSString* cur in [[self imageLib] images])
    {
        // create one card per image
        UIImage* curImage = [[[self imageLib] images] objectForKey:cur];
        Card* newCard = [[Card alloc] initWithIdentifier:index image:curImage];
        [_deck addObject:newCard];
        [newCard release];
        ++index;
    }    
}

#pragma mark - game logic

- (void) newGameWithConfig:(GameConfig *)config
{
    // retain config
    self.curConfig = config;
    
    // load up default image lib
    ImageLib* newLib = [[ImageLib alloc] initWithPlistNamed:[config imageLibName]];
    self.imageLib = newLib;
    [newLib release];
    
    // init deck
    [self initDeck];
    
    // init per-round data structures
    _scratchDeck = [[NSMutableArray array] retain];
    _roundCards = [[NSMutableArray array] retain];
    
    // init timer
    _timeRemaining = [_curConfig gameDuration];
    
    if(GAMEMODE_MULTIPLAYER == [self curGameMode])
    {
        // if multiplayer, don't start game, wait for trigger in NextpeerDelegate
        _shouldStartGame = NO;
        [self resetAttackStates];
    }
    else
    {
        _shouldStartGame = YES;
    }
    _hasFinishedGame = NO;
    _shouldExitGame = NO;
}

- (void) exitGame
{
    // clean per-round data structures
    self.roundCards = nil;
    
    // delete deck
    self.scratchDeck = nil;
    self.deck = nil;
    
    // clear out image lib
    self.imageLib = nil;
}

- (void) restartGame
{
    // restart timer
    _timeRemaining = [_curConfig gameDuration];

    // reset flow variables
    _shouldStartGame = NO;
    _hasFinishedGame = NO;
    _shouldExitGame = NO;
    [self resetAttackStates];
}

- (void) roundCardsRandomInsertCard:(Card*)newCard
{
    unsigned int roundCardsCount = [_roundCards count];
    unsigned int targetIndex = arc4random_uniform(roundCardsCount);
    if([NSNull null] == [_roundCards objectAtIndex:targetIndex])
    {
        // if target slot is empty, insert it
        [_roundCards replaceObjectAtIndex:targetIndex withObject:newCard];
    }
    else
    {
        // otherwise, go to the next entry until we find an empty slot
        unsigned int stepCount = 0;
        ++targetIndex;
        do 
        {
            if(targetIndex >= roundCardsCount)
            {
                // wrap around
                targetIndex = 0;
            }
            if([NSNull null] == [_roundCards objectAtIndex:targetIndex])
            {
                // empty slot, insert and done
                [_roundCards replaceObjectAtIndex:targetIndex withObject:newCard];
                break;
            }
            
            ++stepCount;
            ++targetIndex;
        } while (stepCount < roundCardsCount);
    }
}

// setup a new round
// create a set of cards for the current round by randomly pulling from the scratchDeck
- (void) newRound
{
    int totalCards = self.curConfig.numRows * self.curConfig.numColumns;
    NSAssert(0 == (totalCards % 2), @"total cards per round must be an even number");
    NSAssert(0 == [_roundCards count], @"clear out roundCards before newRound is called");
    
    // init the Round card array with empty slots for shuffle insertion
    for(unsigned int i = 0; i < totalCards; ++i)
    {
        [_roundCards addObject:[NSNull null]];
    }
    
    // fill scratchDeck with template cards from deck
    [_scratchDeck addObjectsFromArray:[self deck]];
    
    // randomly pull from scratchDeck and insert into random slots in Round card array
    while(0 < totalCards)
    {
        if(0 == [_scratchDeck count])
        {
            // if scratchDeck is out of card, replenish it from the deck
            [_scratchDeck addObjectsFromArray:[self deck]];
        }
        
        // randomly pull a card from the scratchDeck
        unsigned int nextIndex = arc4random_uniform([_scratchDeck count]);
        Card* nextCard = [_scratchDeck objectAtIndex:nextIndex];
        
        // create two instances of it using the card from scratchDeck as a template
        Card* newCard1 = [[Card alloc] initWithCard:nextCard];
        Card* newCard2 = [[Card alloc] initWithCard:nextCard];
        [self roundCardsRandomInsertCard:newCard1];
        [self roundCardsRandomInsertCard:newCard2];
        [newCard1 release];
        [newCard2 release];
        [_scratchDeck removeObjectAtIndex:nextIndex];

        totalCards -= 2;
    }

    // clear scratchDeck
    [_scratchDeck removeAllObjects];

    // reset pais matched
    _numConsecutiveMatches = 0;
    
    // DEBUG
    for(id cur in _roundCards)
    {
        NSAssert([NSNull null] != cur, @"_roundCards did not get completely filled, something is wrong");
    }
    // DEBUG
}

- (void) exitRound
{
    [_roundCards removeAllObjects];
}

- (BOOL) matchCards:(Card *)card1 :(Card *)card2
{
    BOOL result = NO;
    if([card1 identifier] == [card2 identifier])
    {
        // matched
        result = YES;
        ++_numConsecutiveMatches;
        
        if(GAMEMODE_MULTIPLAYER != [self curGameMode])
        {
            // reward player bonus time in SinglePlayer mode
            _timeRemaining += TIMEBOOST_PER_MATCH;
        }
    }
    else
    {
        _numConsecutiveMatches = 0;
    }

    // report stats
    [[StatsManager getInstance] reportPairMatched:result];
    
    return result;
}

- (void) update:(NSTimeInterval)elapsed
{
    if(GAMEMODE_MULTIPLAYER == [self curGameMode])
    {
        _timeRemaining = [Nextpeer timeLeftInTournament];    // <-- use time from Nextpeer
    }
    else
    {
        _timeRemaining -= elapsed;
        if(0.0f > _timeRemaining)
        {
            _timeRemaining = 0.0f;
            _hasFinishedGame = YES;
        }
    }
}

- (void) exitRequested
{
    // in multiplayer, forfeit the tournament
    if(GAMEMODE_MULTIPLAYER == [[GameManager getInstance] curGameMode])
    {
        [Nextpeer reportForfeitForCurrentTournament];
    }
    
    // exit the game
    _timeRemaining = 0.0f;
    _shouldExitGame = YES;
}

- (void) startRequested
{
    _shouldStartGame = YES;
}

#pragma mark - multiplayer pushData
- (void) pushAttackToOtherPlayers
{
    // compute a shake angle based on number of consecutive matches
    float factor = (float)(_numConsecutiveMatches) / 6.0f;
    if(1.0f <= factor) factor = 1.0f;
    float angle = M_PI_2 * factor;

    // push it
    NSError* error;
    NSNumber* angleNumber = [NSNumber numberWithFloat:angle];
    NSData* outData = [NSPropertyListSerialization dataWithPropertyList:angleNumber 
                                                                 format:NSPropertyListBinaryFormat_v1_0
                                                                options:0
                                                                  error:&error];
    [Nextpeer pushDataToOtherPlayers:outData];
}

- (void) resetAttackStates
{
    _numAttacksReceived = 0;
    _numAttacksProcessed = 0;
    self.lastAttackerName = nil;
    _lastAttackAngle = 0.0f;
}
#pragma mark - NPTournamentDelegate
-(void)nextpeerDidReceiveTournamentCustomMessage:(NPTournamentCustomMessageContainer*)message
{
    NSError* error;
    NSData* messageData = message.message;
    if(messageData)
    {
        NSNumber* dataNumber = [NSPropertyListSerialization propertyListWithData:messageData
                                                                               options:NSPropertyListImmutable
                                                                                format:NULL
                                                                                 error:&error];
        _lastAttackAngle = [dataNumber floatValue];
    }
    else
    {
        _lastAttackAngle = M_PI_4;
    }
    
    self.lastAttackerName = [NSString stringWithString:[message playerName]];
    ++_numAttacksReceived;
}

#pragma mark - NextpeerDelegate
- (void)nextpeerDidTournamentStartWithDetails:(NPTournamentStartDataContainer *)tournamentContainer
{
    _shouldStartGame = YES;
}

- (void) nextpeerDidTournamentEnd
{
    _hasFinishedGame = YES;
}

- (void) nextpeerDashboardDidDisappear
{
    // if not in tournament, exit to main menu
    if(![Nextpeer isCurrentlyInTournament])
    {
        _shouldExitGame = YES;
    }
}


#pragma mark - Singleton
static GameManager *singleton = nil;

+ (GameManager*) getInstance
{
	@synchronized(self)
	{
		if (!singleton)
		{
			singleton = [[[GameManager alloc] init] retain];
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
