//
//  RedditItem.m
//  RedditBar
//
//  Created by Thomas Buck on 01.12.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import "RedditItem.h"

@implementation RedditItem

@synthesize name, link, comments, isSelf;

+(RedditItem *)itemWithName:(NSString *)name Link:(NSString *)link Comments:(NSString *)comments Self:(BOOL)isSelf {
    RedditItem *i = [[RedditItem alloc] init];
    [i setName:name];
    [i setLink:link];
    [i setComments:comments];
    [i setIsSelf:isSelf];
    return i;
}

@end
