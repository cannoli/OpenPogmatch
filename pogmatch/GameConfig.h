//
//  GameConfig.h
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

#import <UIKit/UIKit.h>

enum GAMEMODES
{
    GAMEMODE_SINGLEPLAYER = 0,
    GAMEMODE_MULTIPLAYER,
    
    GAMEMODE_NUM
};

@interface GameConfig : NSObject
{
    unsigned int _gameMode;
    unsigned int _numRows;
    unsigned int _numColumns;
    NSString* _imageLibName;
    NSTimeInterval _gameDuration;
}
@property (nonatomic,assign) unsigned int gameMode;
@property (nonatomic,readonly) unsigned int numRows;
@property (nonatomic,readonly) unsigned int numColumns;
@property (nonatomic,readonly) NSString* imageLibName;
@property (nonatomic,assign) NSTimeInterval gameDuration;

- (id) initWithImageLibName:(NSString*)libname numRows:(unsigned int)rows numColumns:(unsigned int)cols;
@end
