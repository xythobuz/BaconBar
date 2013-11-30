//
//  AppDelegate.h
//  RedditBar
//
//  Created by Thomas Buck on 30.11.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PrefController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (atomic, retain) IBOutlet NSMenu *statusMenu;

@property (atomic, retain) NSStatusItem *statusItem;
@property (atomic, retain) NSImage *statusImage;
@property (atomic, retain) NSImage *statusHighlightImage;
@property (atomic, retain) PrefController *prefWindow;

-(IBAction)showPreferences:(id)sender;

@end
