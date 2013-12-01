//
//  Reddit.h
//  RedditBar
//
//  Created by Thomas Buck on 01.12.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reddit : NSObject

@property (atomic, retain) NSString *username;
@property (atomic, retain) NSString *modhash;
@property (atomic, retain) NSString *password;

-(id)initWithUsername:(NSString *)name Password:(NSString *)pass;
-(NSString *)queryModhash;

-(id)initWithUsername:(NSString *)name Modhash:(NSString *)hash;
-(BOOL)isAuthenticated;

@end
