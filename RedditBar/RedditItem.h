//
//  RedditItem.h
//  RedditBar
//
//  Created by Thomas Buck on 01.12.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedditItem : NSObject

@property (atomic, retain) NSString *name;
@property (atomic, retain) NSString *link;
@property (atomic, retain) NSString *comments;
@property (atomic) BOOL isSelf;

+(RedditItem *)itemWithName:(NSString *)name Link:(NSString *)link Comments:(NSString *)comments Self:(BOOL)isSelf;

@end
