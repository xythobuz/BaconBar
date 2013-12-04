//
//  AppDelegate.m
//  RedditBar
//
//  Created by Thomas Buck on 30.11.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize statusMenu, statusItem, statusImage, statusHighlightImage, prefWindow, currentState, application, api, firstMenuItem, menuItems, redditItems;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:NSLocalizedString(@"RedditBar", @"Main Menuitem Tooltip")];
    [statusItem setHighlightMode:YES];
    currentState = [[StateModel alloc] init];
    [self defaultPreferences];
    [self loadPreferences];
    [self reloadListWithOptions];
}

-(void)defaultPreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"username"];
    [appDefaults setValue:@"" forKey:@"modhash"];
    [appDefaults setValue:[NSNumber numberWithBool:YES] forKey:@"subscriptions"];
    [appDefaults setValue:[NSNumber numberWithInt:10] forKey:@"length"];
    [store registerDefaults:appDefaults];
}

-(void)savePreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    [store setObject:currentState.username forKey:@"username"];
    [store setObject:currentState.modhash forKey:@"modhash"];
    [store setBool:currentState.useSubscriptions forKey:@"subscriptions"];
    [store setObject:currentState.subreddits forKey:@"subreddits"];
    [store setInteger:currentState.length forKey:@"length"];
    [store synchronize];
}

-(void)loadPreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    [store synchronize];
    [currentState setUsername:[store stringForKey:@"username"]];
    [currentState setModhash:[store stringForKey:@"modhash"]];
    [currentState setUseSubscriptions:[store boolForKey:@"subscriptions"]];
    [currentState setSubreddits:[store arrayForKey:@"subreddits"]];
    [currentState setLength:[store integerForKey:@"length"]];
}

-(void)reloadListNotAuthenticatedCallback {
    [firstMenuItem setTitle:NSLocalizedString(@"Login Error!", @"Statusitem when API is not authenticated")];
    [self clearMenuItems];
    [firstMenuItem setHidden:NO];
}

-(void)reloadListHasFrontpageCallback:(NSArray *)items {
    if (items == nil) {
        [firstMenuItem setTitle:NSLocalizedString(@"Error reading Frontpage!", @"Status api Read error")];
        [self clearMenuItems];
        [firstMenuItem setHidden:NO];
        return;
    }
    redditItems = items;
    [self clearMenuItems];
    [firstMenuItem setHidden:YES];
    [self putItemArrayInMenu:redditItems];
}

-(void)reloadListHasSubredditsCallback:(NSArray *)items {
    if (items == nil) {
        [firstMenuItem setTitle:NSLocalizedString(@"Error reading Subreddits!", @"Status api read error")];
        [self clearMenuItems];
        [firstMenuItem setHidden:NO];
        return;
    }
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
    
    api = [[Reddit alloc] initWithUsername:currentState.username Modhash:currentState.modhash Length:currentState.length];
    [NSThread detachNewThreadSelector:@selector(isAuthenticatedNewModhash:) toTarget:api withObject:self];
}

-(IBAction)linkToOpen:(id)sender {
    NSString *title = [(NSMenuItem *)sender title];
    if ([title isEqualToString:NSLocalizedString(@"Link...", nil)]) {
        for (NSUInteger i = 0; i < [menuItems count]; i++) {
            NSMenuItem *item = [menuItems objectAtIndex:i];
            NSMenu *submenu = item.submenu;
            if (submenu != nil) {
                if (sender == [submenu itemAtIndex:0]) {
                    RedditItem *rItem = [redditItems objectAtIndex:i];
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[rItem link]]];
                    return;
                }
            }
        }
    } else if ([title isEqualToString:NSLocalizedString(@"Comments...", nil)]) {
        for (NSUInteger i = 0; i < [menuItems count]; i++) {
            NSMenuItem *item = [menuItems objectAtIndex:i];
            NSMenu *submenu = item.submenu;
            if (submenu != nil) {
                if (sender == [submenu itemAtIndex:1]) {
                    RedditItem *rItem = [redditItems objectAtIndex:i];
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[rItem comments]]];
                    return;
                }
            }
        }
    } else {
        for (NSUInteger i = 0; i < [menuItems count]; i++) {
            NSMenuItem *item = [menuItems objectAtIndex:i];
            if (sender == item) {
                RedditItem *rItem = [redditItems objectAtIndex:i];
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[rItem link]]];
                [statusMenu removeItem:[menuItems objectAtIndex:i]];
                return;
            }
        }
    }
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
        RedditItem *reddit = [array objectAtIndex:i];
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
        [items addObject:item];
        [statusMenu insertItem:item atIndex:i];
    }
    menuItems = items;
}

-(IBAction)showPreferences:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    prefWindow = [[PrefController alloc] initWithWindowNibName:@"Prefs"];
    [prefWindow setParent:self];
    [prefWindow setState:currentState];
    [prefWindow showWindow:self];
}

-(IBAction)showAbout:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [application orderFrontStandardAboutPanel:self];
}

-(void)prefReturnName:(NSString *)name Modhash:(NSString *)modhash subscriptions:(Boolean)subscriptions subreddits:(NSString *)subreddits length:(NSInteger)length {
    currentState.username = name;
    currentState.modhash = modhash;
    currentState.useSubscriptions = subscriptions;
    currentState.subreddits = [subreddits componentsSeparatedByString: @"\n"];
    currentState.length = length;
    [self savePreferences];
    [self reloadListWithOptions];
}

@end
