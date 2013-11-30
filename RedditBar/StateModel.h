//
//  StateModel.h
//  RedditBar
//
//  Created by Thomas Buck on 30.11.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StateModel : NSObject

@property (atomic, retain) NSString *username;
@property (atomic, retain) NSString *modhash;
@property (atomic) Boolean useSubsciptions;
@property (atomic, retain) NSArray *subreddits;

@end
