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

NSInteger itemsBeforeLinkList = 2;
NSInteger numberOfStaticMenuItems = 10;

#define MULTIPLIER_PM_INTERVALL_TO_SEC 60
#define RECHECK_PM_AFTER_OPEN 7
#define SUBMENU_INDEX_LINK 0
#define SUBMENU_INDEX_COMMENTS 1
#define SUBMENU_INDEX_BOTH 2

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
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [self openUnread:nil];
}

-(void)recreateRefreshTimer {
    if (refreshTimer != nil)
        [refreshTimer invalidate];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:(currentState.refreshInterval * MULTIPLIER_PM_INTERVALL_TO_SEC) target:self selector:@selector(refreshTick:) userInfo:nil repeats:YES];
    [refreshTimer fire];
}

-(void)refreshTick:(NSTimer *)timer {
    [NSThread detachNewThreadSelector:@selector(readPMs:) toTarget:api withObject:self];
}

-(void)readPMsCallback:(NSArray *)items {
    if ((items == nil) || ([items count] < 1) || (((NSNumber *)[items objectAtIndex:0]).integerValue == 0)) {
        [statusItem setImage:statusImage];
        [statusItem setAlternateImage:statusHighlightImage];
        [PMItem setHidden:TRUE];
        [PMSeparator setHidden:TRUE];
    } else {
        [statusItem setImage:orangeredImage];
        [statusItem setAlternateImage:orangeredHighlightImage];
        [PMItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"You've got %ld unread PMs.", @"PM message"), (long)((NSNumber *)[items objectAtIndex:0]).integerValue]];
        [PMItem setHidden:FALSE];
        [PMSeparator setHidden:FALSE];

        if ([items count] >= 2) {
            if (![currentState.lastNotifiedPM isEqualToString:[items objectAtIndex:1]]) {
                currentState.lastNotifiedPM = [items objectAtIndex:1];
                [currentState savePreferences];
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                notification.title = NSLocalizedString(@"New Reddit PM!", @"Notification Title");
                notification.informativeText = [NSString stringWithFormat:NSLocalizedString(@"You've got %ld unread PMs.", nil), (long)((NSNumber *)[items objectAtIndex:0]).integerValue];
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            }
        }
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

-(void)singleItemReloadedCallback:(NSArray *)items {
    if (items != nil) {
        lastFullName = [items objectAtIndex:[items count] - 1]; // last link fullname is at end of array
        items = [items subarrayWithRange:NSMakeRange(0, [items count] - 1)]; // Remove last item
        NSMutableArray *newMenuItems = [NSMutableArray arrayWithArray:menuItems];
        NSMenuItem *item = [self prepareItemForMenu:[items objectAtIndex:0]];
        [newMenuItems addObject:item];
        [statusMenu insertItem:item atIndex:([statusMenu numberOfItems] - numberOfStaticMenuItems + itemsBeforeLinkList)];
        menuItems = newMenuItems;
        redditItems = [redditItems arrayByAddingObjectsFromArray:items];
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

-(void)openAndRemoveAndReloadWithIndex:(NSInteger)index Comments:(Boolean)comments Both:(Boolean)both {
    RedditItem *rItem = [redditItems objectAtIndex:index];
    NSString *url;
    if (comments) {
        url = [rItem comments];
        [rItem setVisitedComments:TRUE];
    } else {
        url = [rItem link];
        [rItem setVisitedLink:TRUE];
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    if (both) {
        if (!comments) {
            url = [rItem comments];
            [rItem setVisitedComments:TRUE];
        } else {
            url = [rItem link];
            [rItem setVisitedLink:TRUE];
        }
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
    
    if (currentState.removeVisited) {
        Boolean removed = FALSE;
        if ((rItem.isSelf && (rItem.visitedLink || rItem.visitedComments)) || ((!rItem.isSelf) && rItem.visitedLink && rItem.visitedComments)) {
            [statusMenu removeItem:[menuItems objectAtIndex:index]];
            removed = TRUE;
        }
        
        if (removed && ([statusMenu numberOfItems] <= numberOfStaticMenuItems)) {
            [self reloadNextList:nil];
        } else {
            if (removed && currentState.reloadAfterVisit) {
                [NSThread detachNewThreadSelector:@selector(readSingleItem:) toTarget:api withObject:self];
            }
        }
    }
}

-(IBAction)linkToOpen:(id)sender {
    NSString *title = [(NSMenuItem *)sender title];
    if ([title isEqualToString:NSLocalizedString(@"Link...", nil)] || [title isEqualToString:NSLocalizedString(@"Comments...", nil)] || [title isEqualToString:NSLocalizedString(@"Both", nil)]) {
        for (NSUInteger i = 0; i < [menuItems count]; i++) {
            NSMenuItem *item = [menuItems objectAtIndex:i];
            NSMenu *submenu = item.submenu;
            Boolean isComments = [title isEqualToString:NSLocalizedString(@"Comments...", nil)];
            Boolean isBoth = [title isEqualToString:NSLocalizedString(@"Both", nil)];
            if (isBoth) {
                isComments = !isComments; // Open comments first, then link
            }
            
            NSInteger index;
            if ([title isEqualToString:NSLocalizedString(@"Link...", nil)])
                index = SUBMENU_INDEX_LINK;
            else if ([title isEqualToString:NSLocalizedString(@"Comments...", nil)])
                index = SUBMENU_INDEX_COMMENTS;
            else
                index = SUBMENU_INDEX_BOTH;
            
            if ((submenu != nil) && (sender == [submenu itemAtIndex:index])) {
                [self openAndRemoveAndReloadWithIndex:i Comments:isComments Both:isBoth];
                break;
            }
        }
    } else {
        for (NSUInteger i = 0; i < [menuItems count]; i++) {
            NSMenuItem *item = [menuItems objectAtIndex:i];
            if (sender == item) {
                [self openAndRemoveAndReloadWithIndex:i Comments:FALSE Both:FALSE];
                break;
            }
        }
    }
}

-(IBAction)openUnread:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.reddit.com/message/unread"]];
    [NSTimer scheduledTimerWithTimeInterval:RECHECK_PM_AFTER_OPEN target:self selector:@selector(refreshTick:) userInfo:nil repeats:NO];
}

-(void)clearMenuItems {
    if (menuItems != nil) {
        for (NSUInteger i = 0; i < [menuItems count]; i++) {
            NSMenuItem *item = [menuItems objectAtIndex:i];
            if ([statusMenu indexOfItem:item] != -1)
                [statusMenu removeItem:item];
        }
        menuItems = nil;
    }
}

-(void)putItemArrayInMenu:(NSArray *)array {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:array.count];
    for (NSUInteger i = 0; i < [array count]; i++) {
        NSMenuItem *item = [self prepareItemForMenu:[array objectAtIndex:i]];
        [items addObject:item];
        [statusMenu insertItem:item atIndex:(i + itemsBeforeLinkList)];
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
        [submenu addItemWithTitle:NSLocalizedString(@"Both", @"Link & Comment item") action:@selector(linkToOpen:) keyEquivalent:@""];
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

-(void)prefsDidSaveReload:(Boolean)shouldReload {
    [currentState savePreferences];
    [self recreateRefreshTimer];
    if (shouldReload) {
        [firstMenuItem setTitle:NSLocalizedString(@"Loading...", nil)];
        [self clearMenuItems];
        [firstMenuItem setHidden:NO];
        lastFullName = nil; // reload from start
        [self reloadListWithOptions];
    }
}

@end
