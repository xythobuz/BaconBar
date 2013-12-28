/*
 * PrefController.h
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
#import <Foundation/Foundation.h>
#import "StateModel.h"

@interface PrefController : NSWindowController

@property (atomic, retain) IBOutlet NSTextField *username;
@property (atomic, retain) IBOutlet NSSecureTextField *password;
@property (atomic, retain) IBOutlet NSButtonCell *subscriptions;
@property (atomic, retain) IBOutlet NSTextView *subreddits;
@property (atomic, retain) IBOutlet NSWindow *win;
@property (atomic, retain) IBOutlet NSTextField *lengthField;
@property (atomic, retain) IBOutlet NSStepper *lengthStepper;
@property (atomic, retain) IBOutlet NSProgressIndicator *progress;
@property (atomic, retain) IBOutlet NSButton *showSubreddit;
@property (atomic, retain) IBOutlet NSTextField *titleField;
@property (atomic, retain) IBOutlet NSStepper *titleStepper;
@property (atomic, retain) IBOutlet NSTextField *refreshField;
@property (atomic, retain) IBOutlet NSStepper *refreshStepper;
@property (atomic, retain) IBOutlet NSPopUpButton *filterSelection;
@property (atomic, retain) IBOutlet NSButton *removeVisited;
@property (atomic, retain) IBOutlet NSButton *reloadAfterVisit;
@property (atomic, retain) IBOutlet NSButton *launchOnLogin;

@property (atomic, retain) NSObject *parent;
@property (atomic, retain) StateModel *state;
@property (atomic) NSInteger length;
@property (atomic) NSInteger titleLength;
@property (atomic) NSInteger refreshInterval;

-(IBAction)buttonSave:(id)sender;
-(IBAction)toggleSubs:(id)sender;
-(IBAction)lengthDidChange:(id)sender;
-(IBAction)titleDidChange:(id)sender;
-(IBAction)refreshDidChange:(id)sender;
- (IBAction)removeVisitedToggled:(id)sender;

@end
