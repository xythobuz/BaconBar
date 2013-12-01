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

-(id)initWithUsername:(NSString *)name Password:(NSString *)pass;
-(NSString *)queryModhash;

-(id)initWithUsername:(NSString *)name Modhash:(NSString *)hash;
-(BOOL)isAuthenticatedNewModhash:(NSString **)newModHash;

-(NSArray *)readFrontpageLength:(NSInteger)length;
-(NSArray *)readSubreddits:(NSArray *)source Length:(NSInteger)length;

-(NSData *)queryAPI:(NSString *)api withData:(NSString *)string andResponse:(NSHTTPURLResponse **)res;
-(NSString *)urlencode:(NSString *)string;


@end
