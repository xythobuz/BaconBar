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

@synthesize username, password, subscriptions, subreddits, win, parent, state, lengthFormat, lengthField, lengthStepper, length;

-(Boolean)isValidList:(NSString *)input {
    NSCharacterSet *invalidChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_\n"] invertedSet];
    if ([input rangeOfCharacterFromSet:invalidChars].location != NSNotFound) {
        return FALSE;
    } else {
        return TRUE;
    }
}

-(void)showWindow:(id)sender {
    [super showWindow:sender];
    
    [username setStringValue:state.username];
    
    // TODO what to do with modhash and password field??
    
    [subscriptions setState:[NSNumber numberWithBool:state.useSubsciptions].integerValue];
    [self toggleSubs:nil]; // Maybe the subreddits field needs to be editable
    
    NSMutableString *reddits = [[NSMutableString alloc] init];
    for(int i = 0; i < [state.subreddits count]; i++) {
        [reddits appendFormat:@"%@\n", [state.subreddits objectAtIndex:i]];
    }
    [subreddits setString:reddits];
    length = state.length;
    [lengthStepper setIntegerValue:length];
    [lengthField setIntegerValue:length];
}

-(IBAction)buttonSave:(id)sender {
    Boolean subs;
    if (subscriptions.state != 0) {
        subs = TRUE;
    } else {
        subs = FALSE;
        if (![self isValidList:subreddits.textStorage.string]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Preferences Error"];
            [alert setInformativeText:@"Subreddit List Invalid!"];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert beginSheetModalForWindow:win modalDelegate:nil didEndSelector:nil contextInfo:nil];
            return;
        }
    }
    
    // TODO if username / password changed, get modhash! Else, use the one we got from init
    NSString *modhash;
    
    AppDelegate *app = (AppDelegate *)parent;
    [app prefReturnName:username.stringValue Modhash:modhash subscriptions:subs subreddits:subreddits.textStorage.string length:length];
    [win performClose:self];
}

-(IBAction)toggleSubs:(id)sender {
    if (subscriptions.state != 0) {
        [subreddits setEditable:FALSE];
    } else {
        [subreddits setEditable:TRUE];
    }
}

-(IBAction)lengthDidChange:(id)sender {
    length = [sender integerValue];
    [lengthStepper setIntegerValue:length];
    [lengthField setIntegerValue:length];
}

@end
