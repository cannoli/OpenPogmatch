//
//  CardView.m
//  pogmatch
//
//  Created by Shu Chiun Cheah on 1/27/12.
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

#import "CardView.h"
#import "GameManager.h"
#import "Card.h"
#import <QuartzCore/QuartzCore.h>

static const float SHAKE_INTERVAL = 0.05f;

@implementation CardView

#pragma mark - properties
@synthesize card = _card;

- (unsigned int) state
{
    return _state;
}

- (void) setState:(unsigned int)state
{
    switch(state)
    {
        case CARD_STATE_ACTIVE:
            [self setEnabled:NO];
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 [self setBackgroundColor:[UIColor colorWithRed:0.31f green:0.48f blue:0.47f alpha:1.0f]];
                                 [_imageView setAlpha:0.0f];                                 
                             }
                             completion:^(BOOL finished){
                                 [_imageView setHidden:YES];
                                 [self setEnabled:YES];
                             }];
            break;
            
        case CARD_STATE_SELECTED:
            [self setBackgroundColor:[UIColor clearColor]];
            [_imageView setAlpha:1.0f];                                 
            [_imageView setHidden:NO];
            break;
            
        default:
        case CARD_STATE_MATCHED:
            [self setEnabled:NO];
            [self setBackgroundColor:[UIColor clearColor]];
            [_imageView setAlpha:1.0f];                                 
            [_imageView setHidden:NO];
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 [self setAlpha:0.0f];
                             }
                             completion:^(BOOL finished){
                                 [self setHidden:YES];
                             }];
            break;
    }
    [self setNeedsDisplay];
}


- (void) shakeCard:(float)angle numTimes:(unsigned int)num
{
    _shakeRange = angle;
    _endCycle = num;
    
    _vel = angle / SHAKE_INTERVAL;
    _numCycles = 0;
}

#pragma mark - init/shutdown
- (id)initWithFrame:(CGRect)frame forCard:(Card *)gameCard
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // retain the card
        _card = [gameCard retain];
        
        // add an image-view to show the card's image
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_imageView setImage:[_card image]];
        [self addSubview:_imageView];
        
        // show a round corner border for this card view
        [[self layer] setCornerRadius:5.0f];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setBorderWidth:1.0f];
        [[self layer] setBorderColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f] CGColor]];        

        // init state (hide image, show backgroundcolor)
        _state = CARD_STATE_ACTIVE;
        [self setBackgroundColor:[UIColor colorWithRed:0.31f green:0.48f blue:0.47f alpha:1.0f]];
        [_imageView setHidden:YES];
        
        // init anim
        _shakeRange = 0.0f;
        _vel = 0.0f;
        _rotation = 0.0f;
        _numCycles = 0;
        _endCycle = 0;
    }
    return self;
}

- (void) dealloc
{
    [_imageView setImage:nil];
    [_imageView removeFromSuperview];
    [_imageView release];
    [_card release];
    [super dealloc];
}

#pragma mark - animation
- (void) updateAnim:(NSTimeInterval)elapsed
{
    if(0.0f < _shakeRange)
    {
        _rotation += (elapsed * _vel);
        if((0.0f < _vel) && (_shakeRange < _rotation))
        {
            // flip velocity
            _vel = -_vel;
            ++_numCycles;
            
            // clamp rotation
            _rotation = _shakeRange;
        }
        else if((0.0f > _vel) && (-_shakeRange > _rotation))
        {
            // flip velocity
            _vel = -_vel;
            ++_numCycles;
            
            // clamp rotation
            _rotation = -_shakeRange;
        }
        
        CGAffineTransform rt = CGAffineTransformMakeRotation(_rotation);
        [self setTransform:rt];   
        
        if(_endCycle < _numCycles)
        {
            // stop after endCycle
            _shakeRange = 0.0f;
        }
    }
}

@end
