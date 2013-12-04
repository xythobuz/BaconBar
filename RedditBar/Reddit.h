//
//  Reddit.h
//  RedditBar
//
//  Created by Thomas Buck on 01.12.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RedditItem.h"

@interface Reddit : NSObject

@property (atomic, retain) NSString *username;
@property (atomic, retain) NSString *modhash;
@property (atomic, retain) NSString *password;
@property (atomic) NSInteger length;
@property (atomic, retain) NSArray *subreddits;

// Used by Pref Window, unthreaded
-(id)initWithUsername:(NSString *)name Password:(NSString *)pass;
-(NSString *)queryModhash;

// Used by MainMenu
-(id)initWithUsername:(NSString *)name Modhash:(NSString *)hash Length:(NSInteger)leng;

// Use Threaded!
-(void)isAuthenticatedNewModhash:(id)parent;
-(void)readFrontpage:(id)parent;
-(void)readSubreddits:(id)parent;

// Internal
-(NSData *)queryAPI:(NSString *)api withData:(NSString *)string andResponse:(NSHTTPURLResponse **)res;
-(NSString *)urlencode:(NSString *)string;


@end
