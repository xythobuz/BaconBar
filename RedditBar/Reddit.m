//
//  Reddit.m
//  RedditBar
//
//  Created by Thomas Buck on 01.12.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import "Reddit.h"

@implementation Reddit

@synthesize username, modhash, password;

-(id)initWithUsername:(NSString *)name Modhash:(NSString *)hash {
    self = [super init];
    if (self) {
        username = name;
        modhash = hash;
        password = nil;
    }
    return self;
}

-(id)initWithUsername:(NSString *)name Password:(NSString *)pass {
    self = [super init];
    if (self) {
        username = name;
        modhash = nil;
        password = pass;
    }
    return self;
}

-(NSString *)queryModhash {
    sleep(1);
    return nil;
}

-(BOOL)isAuthenticated {
    return FALSE;
}

@end
