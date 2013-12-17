/*
 * AppDelegate.h
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
#import <Cocoa/Cocoa.h>
#import "PrefController.h"
#import "StateModel.h"
#import "Reddit.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (atomic, retain) IBOutlet NSMenu *statusMenu;
@property (atomic, retain) IBOutlet NSApplication *application;
@property (atomic, retain) IBOutlet NSMenuItem *firstMenuItem;
@property (atomic, retain) IBOutlet NSMenuItem *PMItem;
@property (atomic, retain) IBOutlet NSMenuItem *PMSeparator;

@property (atomic, retain) NSStatusItem *statusItem;
@property (atomic, retain) NSImage *statusImage;
@property (atomic, retain) NSImage *statusHighlightImage;
@property (atomic, retain) NSImage *orangeredImage;
@property (atomic, retain) NSImage *orangeredHighlightImage;
@property (atomic, retain) PrefController *prefWindow;
@property (atomic, retain) StateModel *currentState;
@property (atomic, retain) Reddit *api;
@property (atomic, retain) NSArray *menuItems;
@property (atomic, retain) NSArray *redditItems;
@property (atomic, retain) NSString *lastFullName;
@property (atomic, retain) NSTimer *refreshTimer;

-(IBAction)showPreferences:(id)sender;
-(IBAction)showAbout:(id)sender;
-(IBAction)reloadCompleteList:(id)sender;
-(IBAction)reloadNextList:(id)sender;
-(IBAction)linkToOpen:(id)sender;
-(IBAction)openUnread:(id)sender;

-(void)reloadListWithOptions;
-(void)reloadListIsAuthenticatedCallback;
-(void)reloadListNotAuthenticatedCallback;
-(void)reloadListHasSubredditsCallback:(NSArray *)items;
-(void)reloadListHasFrontpageCallback:(NSArray *)items;
-(void)readPMsCallback:(NSNumber *)items;

-(void)prefReturnName:(NSString *)name Modhash:(NSString *)modhash subscriptions:(Boolean)subscriptions subreddits:(NSString *)subreddits length:(NSInteger)length printSubs:(Boolean)showSubreddits titleLength:(NSInteger)titleLength refresh:(NSInteger)refreshInterval;

@end
