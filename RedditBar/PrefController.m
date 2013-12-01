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

NSString *modhashSetLiteral = @"__MODHASH__IS__SET__";
NSString *subredditCharacters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_\n";

@synthesize username, password, subscriptions, subreddits, win, parent, state, lengthFormat, lengthField, lengthStepper, length, progress;

-(Boolean)isValidList:(NSString *)input {
    NSCharacterSet *invalidChars = [[NSCharacterSet characterSetWithCharactersInString:subredditCharacters] invertedSet];
    if ([input rangeOfCharacterFromSet:invalidChars].location != NSNotFound) {
        return FALSE;
    } else {
        return TRUE;
    }
}

-(void)showWindow:(id)sender {
    [super showWindow:sender];
    [username setStringValue:state.username];
    if (![state.modhash isEqualToString:@""]) {
        [password setStringValue:modhashSetLiteral];
    }
    [subscriptions setState:[NSNumber numberWithBool:state.useSubsciptions].integerValue];
    [self toggleSubs:nil]; // Maybe the subreddits field needs to be editable
    NSMutableString *reddits = [[NSMutableString alloc] init];
    for(int i = 0; i < [state.subreddits count]; i++) {
        if (![[state.subreddits objectAtIndex:i] isEqualToString:@""])
            [reddits appendFormat:@"%@\n", [state.subreddits objectAtIndex:i]];
    }
    [subreddits setString:reddits];
    length = state.length;
    [lengthStepper setIntegerValue:length];
    [lengthField setIntegerValue:length];
    [progress setUsesThreadedAnimation:YES];
}

-(IBAction)buttonSave:(id)sender {
    if ([username.stringValue isEqualToString:@""]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Authentication Error"];
        [alert setInformativeText:@"Please enter a username!"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:win modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }
    
    if ([state.modhash isEqualToString:@""] && [password.stringValue isEqualToString:@""]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Authentication Error"];
        [alert setInformativeText:@"Please enter a password!"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:win modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }
    
    NSString *modhash = state.modhash;
    if (![password.stringValue isEqualToString:modhashSetLiteral]) {
        [progress startAnimation:self];
        Reddit *api = [[Reddit alloc] initWithUsername:username.stringValue Password:password.stringValue];
        modhash = [api queryModhash];
        [progress stopAnimation:self];
        if ((modhash == nil) || ([modhash isEqualToString:@""])) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Authentication Error"];
            [alert setInformativeText:@"Wrong Username or Password!"];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert beginSheetModalForWindow:win modalDelegate:nil didEndSelector:nil contextInfo:nil];
            return;
        }
    }
    
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
