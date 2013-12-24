/*
 * AppDelegate.m
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
#import "AppDelegate.h"

@implementation AppDelegate

@synthesize statusMenu, statusItem, statusImage, statusHighlightImage, orangeredImage, orangeredHighlightImage, prefWindow, currentState, application, api, firstMenuItem, menuItems, redditItems, lastFullName, refreshTimer, PMItem, PMSeparator;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    orangeredImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"orangered" ofType:@"png"]];
    orangeredHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"orangered-alt" ofType:@"png"]];
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:NSLocalizedString(@"RedditBar", @"Main Menuitem Tooltip")];
    [statusItem setHighlightMode:YES];
    currentState = [[StateModel alloc] init];
    [currentState registerDefaultPreferences];
    [currentState loadPreferences];
    lastFullName = nil;
    [self reloadListWithOptions];
    [self recreateRefreshTimer];
}

-(void)recreateRefreshTimer {
    if (refreshTimer != nil)
        [refreshTimer invalidate];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:(currentState.refreshInterval * 60) target:self selector:@selector(refreshTick:) userInfo:nil repeats:YES];
    [refreshTimer fire];
}

-(void)refreshTick:(NSTimer *)timer {
    [NSThread detachNewThreadSelector:@selector(readPMs:) toTarget:api withObject:self];
}

-(void)readPMsCallback:(NSNumber *)items {
    if ((items == nil) || ([items integerValue] == 0)) {
        [statusItem setImage:statusImage];
        [statusItem setAlternateImage:statusHighlightImage];
        [PMItem setHidden:TRUE];
        [PMSeparator setHidden:TRUE];
    } else {
        [statusItem setImage:orangeredImage];
        [statusItem setAlternateImage:orangeredHighlightImage];
        [PMItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"You've got %ld unread PMs!", @"PM message"), (long)items.integerValue]];
        [PMItem setHidden:FALSE];
        [PMSeparator setHidden:FALSE];
    }
}

-(void)reloadListNotAuthenticatedCallback {
    [firstMenuItem setTitle:NSLocalizedString(@"Login Error!", @"Statusitem when API is not authenticated")];
    [self clearMenuItems];
    [firstMenuItem setHidden:NO];
}

-(void)reloadListHasFrontpageCallback:(NSArray *)items {
    [self reloadListHasXCallback:items ErrorMessage:NSLocalizedString(@"Error reading Frontpage!", @"Status api Read error")];
}

-(void)reloadListHasSubredditsCallback:(NSArray *)items {
    [self reloadListHasXCallback:items ErrorMessage:NSLocalizedString(@"Error reading Subreddits!", @"Status api read error")];
}

-(void)reloadListHasXCallback:(NSArray *)items ErrorMessage:(NSString*)error {
    if (items == nil) {
        [firstMenuItem setTitle:error];
        [self clearMenuItems];
        [firstMenuItem setHidden:NO];
        return;
    }
    lastFullName = [items objectAtIndex:[items count] - 1]; // last link fullname is at end of array
    items = [items subarrayWithRange:NSMakeRange(0, [items count] - 1)]; // Remove last item
    redditItems = items;
    [self clearMenuItems];
    [firstMenuItem setHidden:YES];
    [self putItemArrayInMenu:redditItems];
}

-(void)reloadListIsAuthenticatedCallback {
    if (currentState.useSubscriptions) {
        [NSThread detachNewThreadSelector:@selector(readFrontpage:) toTarget:api withObject:self];
    } else {
        [api setSubreddits:currentState.subreddits];
        [NSThread detachNewThreadSelector:@selector(readSubreddits:) toTarget:api withObject:self];
    }
}

-(void)reloadListWithOptions {
    if ([currentState.modhash isEqualToString:@""]) {
        [firstMenuItem setTitle:NSLocalizedString(@"Not logged in!", @"Statusitem when no modhash is stored")];
        [self clearMenuItems];
        [firstMenuItem setHidden:NO];
        [self showPreferences:nil];
        return;
    }
    
    api = [[Reddit alloc] initWithUsername:currentState.username Modhash:currentState.modhash Length:currentState.length TitleLength:currentState.titleLength];
    [NSThread detachNewThreadSelector:@selector(isAuthenticatedNewModhash:) toTarget:api withObject:self];
}

- (IBAction)reloadCompleteList:(id)sender {
    [firstMenuItem setTitle:NSLocalizedString(@"Loading...", @"Statusitem when user clicks reload")];
    [self clearMenuItems];
    [firstMenuItem setHidden:NO];
    lastFullName = nil; // reload from start
    [self reloadListWithOptions];
}

- (IBAction)reloadNextList:(id)sender {
    [firstMenuItem setTitle:NSLocalizedString(@"Loading...", nil)];
    [self clearMenuItems];
    [firstMenuItem setHidden:NO];
    [self reloadListWithOptions];
}

-(void)openAndRemoveAndReloadWithIndex:(NSInteger)index Comments:(Boolean)comments {
    RedditItem *rItem = [redditItems objectAtIndex:index];
    NSString *url;
    if (comments)
        url = [rItem comments];
    else
        url = [rItem link];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    
    if (currentState.removeVisited) {
        // TODO remove selfpost, remove submenu if link & comments visited
        //[statusMenu removeItem:[menuItems objectAtIndex:i]];
        
        Boolean removed = TRUE;
        Boolean listNowEmpty = TRUE;
        
        if (removed && listNowEmpty) {
            [self reloadNextList:nil];
        } else {
            if (removed && currentState.reloadAfterVisit) {
                // TODO load one more item!
            }
        }
    }
}

-(IBAction)linkToOpen:(id)sender {
    NSString *title = [(NSMenuItem *)sender title];
    if ([title isEqualToString:NSLocalizedString(@"Link...", nil)] || [title isEqualToString:NSLocalizedString(@"Comments...", nil)]) {
        for (NSUInteger i = 0; i < [menuItems count]; i++) {
            NSMenuItem *item = [menuItems objectAtIndex:i];
            NSMenu *submenu = item.submenu;
            if ((submenu != nil) && (sender == [submenu itemAtIndex:([title isEqualToString:NSLocalizedString(@"Link...", nil)] ? 0 : 1)])) {
                [self openAndRemoveAndReloadWithIndex:i Comments:[title isEqualToString:NSLocalizedString(@"Comments...", nil)]];
                break;
            }
        }
    } else {
        for (NSUInteger i = 0; i < [menuItems count]; i++) {
            NSMenuItem *item = [menuItems objectAtIndex:i];
            if (sender == item) {
                [self openAndRemoveAndReloadWithIndex:i Comments:FALSE];
                break;
            }
        }
    }
}

-(IBAction)openUnread:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.reddit.com/message/unread"]];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refreshTick:) userInfo:nil repeats:NO];
}

-(void)clearMenuItems {
    if (menuItems != nil) {
        for (NSUInteger i = 0; i < [menuItems count]; i++) {
            [statusMenu removeItem:[menuItems objectAtIndex:i]];
        }
        menuItems = nil;
    }
}

-(void)putItemArrayInMenu:(NSArray *)array {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:array.count];
    for (NSUInteger i = 0; i < [array count]; i++) {
        NSMenuItem *item = [self prepareItemForMenu:[array objectAtIndex:i]];
        [items addObject:item];
        [statusMenu insertItem:item atIndex:(i + 2)];
    }
    menuItems = items;
}

-(NSMenuItem *)prepareItemForMenu:(RedditItem *)reddit {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    [item setTitle:reddit.name];
    if (![reddit.name isEqualToString:reddit.fullName])
        [item setToolTip:reddit.fullName];
    if (reddit.isSelf) {
        [item setAction:@selector(linkToOpen:)];
        [item setKeyEquivalent:@""];
    } else {
        NSMenu *submenu = [[NSMenu alloc] init];
        [submenu addItemWithTitle:NSLocalizedString(@"Link...", @"Link item") action:@selector(linkToOpen:) keyEquivalent:@""];
        [submenu addItemWithTitle:NSLocalizedString(@"Comments...", @"comment item") action:@selector(linkToOpen:) keyEquivalent:@""];
        [item setSubmenu:submenu];
    }
    return item;
}

-(IBAction)showPreferences:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    prefWindow = [[PrefController alloc] initWithWindowNibName:@"Prefs"];
    [prefWindow setParent:self];
    [prefWindow setState:currentState];
    [prefWindow showWindow:self];
    [[prefWindow window] makeKeyAndOrderFront:self];
}

-(IBAction)showAbout:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [application orderFrontStandardAboutPanel:self];
}

-(void)prefsDidSave {
    [currentState savePreferences];
    [firstMenuItem setTitle:NSLocalizedString(@"Loading...", nil)];
    [self clearMenuItems];
    [firstMenuItem setHidden:NO];
    lastFullName = nil; // reload from start
    [self reloadListWithOptions];
    [self recreateRefreshTimer];
}

@end
