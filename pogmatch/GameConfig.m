//
//  GameConfig.m
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

#import "GameConfig.h"

@implementation GameConfig
@synthesize gameMode = _gameMode;
@synthesize numRows = _numRows;
@synthesize numColumns = _numColumns;
@synthesize imageLibName = _imageLibName;
@synthesize gameDuration = _gameDuration;

- (id)initWithImageLibName:(NSString *)libname numRows:(unsigned int)rows numColumns:(unsigned int)cols
{
    self = [super init];
    if (self) 
    {
        _imageLibName = [libname retain];
        
        unsigned int total = rows * cols;
        if(0 < (total % 2))
        {
            // adjust rows and columns to the closest config that results in even number of cards
            // if necessary
            if(cols < rows)
            {
                --rows;
            }
            else
            {
                --cols;
            }
        }
        
        // min-clamp at 2
        if(2 > rows)
        {
            rows = 2;
        }
        if(2 > cols)
        {
            cols = 2;
        }
        _numRows = rows;
        _numColumns = cols;
    
        // default configs
        _gameDuration = 60.0f;     // 60 seconds
        _gameMode = GAMEMODE_SINGLEPLAYER;
    }
    return self;
}

- (void) dealloc
{
    [_imageLibName release];
    [super dealloc];
}


@end
