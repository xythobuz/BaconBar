//
//  AppDelegate.h
//  RedditBar
//
//  Created by Thomas Buck on 30.11.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PrefController.h"
#import "StateModel.h"
#import "Reddit.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (atomic, retain) IBOutlet NSMenu *statusMenu;
@property (atomic, retain) IBOutlet NSApplication *application;

@property (atomic, retain) NSStatusItem *statusItem;
@property (atomic, retain) NSImage *statusImage;
@property (atomic, retain) NSImage *statusHighlightImage;
@property (atomic, retain) PrefController *prefWindow;
@property (atomic, retain) StateModel *currentState;
@property (atomic, retain) Reddit *api;

-(IBAction)showPreferences:(id)sender;
-(IBAction)showAbout:(id)sender;

-(void)prefReturnName:(NSString *)name Modhash:(NSString *)modhash subscriptions:(Boolean)subscriptions subreddits:(NSString *)subreddits length:(NSInteger)length;

@end
