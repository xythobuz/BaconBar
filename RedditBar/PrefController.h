//
//  PrefController.h
//  RedditBar
//
//  Created by Thomas Buck on 30.11.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StateModel.h"

@interface PrefController : NSWindowController

@property (atomic, retain) IBOutlet NSTextField *username;
@property (atomic, retain) IBOutlet NSSecureTextField *password;
@property (atomic, retain) IBOutlet NSButtonCell *subscriptions;
@property (atomic, retain) IBOutlet NSTextView *subreddits;
@property (atomic, retain) IBOutlet NSWindow *win;
@property (atomic, retain) IBOutlet NSNumberFormatter *lengthFormat;
@property (atomic, retain) IBOutlet NSTextField *lengthField;
@property (atomic, retain) IBOutlet NSStepper *lengthStepper;
@property (atomic, retain) NSObject *parent;
@property (atomic, retain) StateModel *state;
@property (atomic) NSInteger length;

-(IBAction)buttonSave:(id)sender;
-(IBAction)toggleSubs:(id)sender;
-(IBAction)lengthDidChange:(id)sender;

@end
