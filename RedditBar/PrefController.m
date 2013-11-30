//
//  PrefController.m
//  RedditBar
//
//  Created by Thomas Buck on 30.11.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import "PrefController.h"
#import "AppDelegate.h"

@implementation PrefController

@synthesize username, password, subscriptions, subreddits, win, parent;

-(Boolean)isValidList:(NSString *)input validated:(NSString **)output {
    // TODO: Check if subreddit input is valid
    *output = input;
    return TRUE;
}

-(IBAction)buttonSave:(id)sender {
    Boolean subs;
    NSString *reddits;
    if (subscriptions.state != 0) {
        subs = TRUE;
    } else {
        subs = FALSE;
        if (![self isValidList:subreddits.textStorage.string validated:&reddits]) {
            // TODO show error message
            return;
        }
    }
    AppDelegate *app = (AppDelegate *)parent;
    [app prefReturnName:username.stringValue Pass:password.stringValue subscriptions:subs subreddits:reddits];
    [win performClose:self];
}

-(IBAction)toggleSubs:(id)sender {
    if (subscriptions.state != 0) {
        // Use subscriptions
        [subreddits setEditable:FALSE];
        [subreddits setString:@""];
    } else {
        // Use userlist
        [subreddits setEditable:TRUE];
        [subreddits setString:@"One Subreddit per line!"];
    }
}

-(void)showWindow:(id)sender {
    [super showWindow:sender];
    
    
}

@end
