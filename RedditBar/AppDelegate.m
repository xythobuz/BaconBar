//
//  AppDelegate.m
//  RedditBar
//
//  Created by Thomas Buck on 30.11.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize statusMenu, statusItem, statusImage, statusHighlightImage, prefWindow, currentState, application;

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
    [store setBool:currentState.useSubsciptions forKey:@"subscriptions"];
    [store setObject:currentState.subreddits forKey:@"subreddits"];
    [store setInteger:currentState.length forKey:@"length"];
    [store synchronize];
}

-(void)loadPreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    [store synchronize];
    [currentState setUsername:[store stringForKey:@"username"]];
    [currentState setModhash:[store stringForKey:@"modhash"]];
    [currentState setUseSubsciptions:[store boolForKey:@"subscriptions"]];
    [currentState setSubreddits:[store arrayForKey:@"subreddits"]];
    [currentState setLength:[store integerForKey:@"length"]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Reddit Bar"];
    [statusItem setHighlightMode:YES];
    
    [self defaultPreferences];
    currentState = [[StateModel alloc] init];
    [self loadPreferences]; // Fill currentState
    
    // TODO apply currentState
    // TODO reload menu list
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
    currentState.useSubsciptions = subscriptions;
    currentState.subreddits = [subreddits componentsSeparatedByString: @"\n"];
    currentState.length = length;
    [self savePreferences]; // write currentState
    
    // TODO apply currentState
    // TODO reload menu list
}

@end
