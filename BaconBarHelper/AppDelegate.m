//
//  AppDelegate.m
//  BaconBarHelper
//
//  Created by Thomas Buck on 28.12.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *appName = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] stringByReplacingOccurrencesOfString:@"Helper" withString:@""];
    BOOL alreadyRunning = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running) {
        if ([[app bundleIdentifier] isEqualToString:appName]) {
            alreadyRunning = YES;
        }
    }
    
    if (!alreadyRunning) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSArray *p = [path pathComponents];
        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p]; // /Applications/BaconBar.app/Contents/Library/LoginItems/BaconBarHelper.app
        [pathComponents removeLastObject]; // /Applications/BaconBar.app/Contents/Library/LoginItems
        [pathComponents removeLastObject]; // /Applications/BaconBar.app/Contents/Library
        [pathComponents removeLastObject]; // /Applications/BaconBar.app/Contents
        [pathComponents removeLastObject]; // /Applications/BaconBar.app
        NSString *newPath = [NSString pathWithComponents:pathComponents];
        [[NSWorkspace sharedWorkspace] launchApplication:newPath];
    }
    
    [NSApp terminate:nil];
}

@end
