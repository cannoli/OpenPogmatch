//
//  PogUIProgressBar.m
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

#import "PogUIProgressBar.h"
#import <QuartzCore/QuartzCore.h>

@implementation PogUIProgressBar

#pragma mark - properties
@synthesize fillColor = _fillColor;
@synthesize borderColor = _borderColor;

- (void) setProgressPercent:(CGFloat)progressPercent
{
    if(100.0f < progressPercent)
    {
        _progressPercent = 100.0f;
    }
    else
    {
        _progressPercent = progressPercent;
    }
}

- (CGFloat) progressPercent
{
    return _progressPercent;
}


#pragma mark - init / shutdown
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        _fillColor = [[UIColor blueColor] retain];
        _borderColor = [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f] retain];
        _progressPercent = 50.0f;
    
        [[self layer] setCornerRadius:5.0f];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setBorderWidth:1.0f];
        [[self layer] setBorderColor:[_borderColor CGColor]];        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        _fillColor = [[UIColor blueColor] retain];
        _borderColor = [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f] retain];
        _progressPercent = 50.0f;

        [[self layer] setCornerRadius:5.0f];
        [[self layer] setMasksToBounds:YES];
        [[self layer] setBorderWidth:1.0f];
        [[self layer] setBorderColor:[_borderColor CGColor]];        
    }
    return self;
}

- (void) dealloc
{
    [_fillColor release];
    [_borderColor release];
    [super dealloc];
}

#pragma mark - draw

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.5);
    [_borderColor setStroke];
    [_fillColor setFill];
    
    // fill
    CGRect percentFrame = CGRectMake(0.0f, 
                                     0.0f, 
                                     (_progressPercent / 100.0f) * self.bounds.size.width,
                                     self.bounds.size.height);
    UIRectFill(percentFrame);
}

@end
