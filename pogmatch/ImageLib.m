//
//  ImageLib.m
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

#import "ImageLib.h"

@interface ImageLib (Private)
- (void) loadImagesFromNameArray:(NSArray*)nameArray;
@end

@implementation ImageLib
@synthesize images = _images;

- (id) initWithPlistNamed:(NSString *)plistFilename
{
    self = [super init];
    if(self)
    {
        NSString* path = [[NSBundle mainBundle] pathForResource:plistFilename ofType:@"plist"];
        NSDictionary* config = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray* nameArray = [config objectForKey:@"images"];
        [self loadImagesFromNameArray:nameArray];
    }
    return self;
}

- (void) dealloc
{
    [_images release];
    [super dealloc];
}

#pragma mark - private methods
- (void) loadImagesFromNameArray:(NSArray *)nameArray
{
    // create the images dictionary
    _images = [[NSMutableDictionary dictionary] retain];
    
    // load images
    if(nameArray)
    {
        for(NSString* cur in nameArray)
        {
            UIImage* newImage = [UIImage imageNamed:cur];
            if(newImage)
            {
                [_images setObject:newImage forKey:cur];
            }
        }
    }
}

@end
