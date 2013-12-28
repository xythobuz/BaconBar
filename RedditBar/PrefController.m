/*
 * PrefController.m
 *
 * Copyright (c) 2013, Thomas Buck <xythobuz@xythobuz.de>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import "PrefController.h"
#import "AppDelegate.h"

@implementation PrefController

NSString *modhashSetLiteral = @"__MODHASH__IS__SET__";
NSString *subredditCharacters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_\n";

@synthesize username, password, subscriptions, subreddits, win, parent, state, lengthField, lengthStepper, length, progress, showSubreddit, titleField, titleStepper, titleLength, refreshField, refreshStepper, refreshInterval, filterSelection, removeVisited, reloadAfterVisit, launchOnLogin;

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
    [subscriptions setState:[NSNumber numberWithBool:state.useSubscriptions].integerValue];
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
    titleLength = state.titleLength;
    [titleStepper setIntegerValue:titleLength];
    [titleField setIntegerValue:titleLength];
    refreshInterval = state.refreshInterval;
    [refreshStepper setIntegerValue:refreshInterval];
    [refreshField setIntegerValue:refreshInterval];
    [progress setUsesThreadedAnimation:YES];
    [showSubreddit setState:[NSNumber numberWithBool:state.showSubreddit].integerValue];
    if ([state.filter isEqualToString:@"hot"]) {
        [filterSelection selectItemAtIndex:0];
    } else {
        [filterSelection selectItemAtIndex:1];
    }
    if (state.removeVisited) {
        [removeVisited setState:1];
        [reloadAfterVisit setEnabled:TRUE];
    } else {
        [removeVisited setState:0];
        [reloadAfterVisit setEnabled:FALSE];
    }
    if (state.reloadAfterVisit) {
        [reloadAfterVisit setState:1];
    } else {
        [reloadAfterVisit setState:0];
    }
    [launchOnLogin setState:[NSNumber numberWithBool:state.startOnLogin].integerValue];
}

-(IBAction)buttonSave:(id)sender {
    if ([username.stringValue isEqualToString:@""]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alert setMessageText:NSLocalizedString(@"Authentication Error", @"Pref Error")];
        [alert setInformativeText:NSLocalizedString(@"Please enter a username!", @"Pref Error")];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:win modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }
    
    if ([state.modhash isEqualToString:@""] && [password.stringValue isEqualToString:@""]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alert setMessageText:NSLocalizedString(@"Authentication Error", nil)];
        [alert setInformativeText:NSLocalizedString(@"Please enter a password!", @"Pref Error")];
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
            [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
            [alert setMessageText:NSLocalizedString(@"Authentication Error", nil)];
            [alert setInformativeText:NSLocalizedString(@"Wrong Username or Password!", @"Pref API Error")];
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
            [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
            [alert setMessageText:NSLocalizedString(@"Preferences Error", @"Pref Error")];
            [alert setInformativeText:NSLocalizedString(@"Subreddit List Invalid!", @"Pref Error")];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert beginSheetModalForWindow:win modalDelegate:nil didEndSelector:nil contextInfo:nil];
            return;
        }
    }
    Boolean print;
    if (showSubreddit.state != 0)
        print = TRUE;
    else
        print = FALSE;
    Boolean remove;
    if (removeVisited.state != 0)
        remove = TRUE;
    else
        remove = FALSE;
    Boolean reload;
    if (reloadAfterVisit.state != 0)
        reload = TRUE;
    else
        reload = FALSE;
    Boolean start;
    if (launchOnLogin.state != 0)
        start = TRUE;
    else
        start = FALSE;
    
    NSArray *subredditsToUse = [subreddits.textStorage.string componentsSeparatedByString: @"\n"];
    
    Boolean changesRequireReload = FALSE;
    if (![[username stringValue] isEqualToString:state.username])
        changesRequireReload = TRUE;
    if (![modhash isEqualToString:state.modhash])
        changesRequireReload = TRUE;
    if (subs != state.useSubscriptions)
        changesRequireReload = TRUE;
    if (subs && (![state.subreddits isEqualToArray:subredditsToUse]))
        changesRequireReload = TRUE;
    if ([lengthField integerValue] != state.length)
        changesRequireReload = TRUE;
    if (print != state.showSubreddit)
        changesRequireReload = TRUE;
    if ([titleField integerValue] != state.titleLength)
        changesRequireReload = TRUE;
    if (![[filterSelection titleOfSelectedItem] isEqualToString:state.filter])
        changesRequireReload = TRUE;
    
    state.username = username.stringValue;
    state.modhash = modhash;
    state.useSubscriptions = subs;
    state.subreddits = subredditsToUse;
    state.length = [lengthField integerValue];
    state.showSubreddit = print;
    state.titleLength = [titleField integerValue];
    state.refreshInterval = [refreshField integerValue];
    state.filter = [filterSelection titleOfSelectedItem];
    state.removeVisited = remove;
    state.reloadAfterVisit = reload;
    state.startOnLogin = start;
    [(AppDelegate *)parent prefsDidSaveReload:changesRequireReload];
    [win performClose:self];
}

-(IBAction)toggleSubs:(id)sender {
    if (subscriptions.state != 0) {
        [subreddits setEditable:FALSE];
        [subscriptions setTitle:NSLocalizedString(@"Use Subscriptions", @"Pref Checkbox State 1")];
    } else {
        [subreddits setEditable:TRUE];
        [subscriptions setTitle:NSLocalizedString(@"Use Subreddits list", @"Pref Checkbox State 0")];
    }
}

-(IBAction)lengthDidChange:(id)sender {
    length = [sender integerValue];
    [lengthStepper setIntegerValue:length];
    [lengthField setIntegerValue:length];
}

-(IBAction)titleDidChange:(id)sender {
    titleLength = [sender integerValue];
    [titleStepper setIntegerValue:titleLength];
    [titleField setIntegerValue:titleLength];
}

-(IBAction)refreshDidChange:(id)sender {
    refreshInterval = [sender integerValue];
    [refreshStepper setIntegerValue:refreshInterval];
    [refreshField setIntegerValue:refreshInterval];
}

- (IBAction)removeVisitedToggled:(id)sender {
    if (removeVisited.state != 0) {
        [reloadAfterVisit setEnabled:TRUE];
    } else {
        [reloadAfterVisit setEnabled:FALSE];
    }
}

@end
