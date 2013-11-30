//
//  PrefController.h
//  RedditBar
//
//  Created by Thomas Buck on 30.11.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrefController : NSWindowController

@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSSecureTextField *password;
@property (atomic, retain) IBOutlet NSButtonCell *subscriptions;
@property (atomic, retain) IBOutlet NSTextView *subreddits;
@property (atomic, retain) IBOutlet NSWindow *win;
@property (atomic, retain) NSObject *parent;

-(IBAction)buttonSave:(id)sender;
-(IBAction)toggleSubs:(id)sender;

-(void)setParent:(NSObject *)par;

@end
