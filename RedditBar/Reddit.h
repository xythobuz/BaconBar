/*
 * Reddit.h
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
#import "RedditItem.h"

@interface Reddit : NSObject

@property (atomic, retain) NSString *username;
@property (atomic, retain) NSString *modhash;
@property (atomic, retain) NSString *password;
@property (atomic, retain) NSString *version;
@property (atomic, retain) NSString *appName;
@property (atomic, retain) NSString *author;
@property (atomic) NSInteger length;
@property (atomic, retain) NSArray *subreddits;

// Used by Pref Window, unthreaded
-(id)initWithUsername:(NSString *)name Password:(NSString *)pass;
-(NSString *)queryModhash;

// Used by MainMenu
-(id)initWithUsername:(NSString *)name Modhash:(NSString *)hash Length:(NSInteger)leng;

// Use Threaded!
-(void)isAuthenticatedNewModhash:(id)parent;
-(void)readFrontpage:(id)parent;
-(void)readSubreddits:(id)parent;

// Internal
-(NSData *)queryAPI:(NSString *)api withData:(NSString *)string andResponse:(NSHTTPURLResponse **)res;
-(NSString *)urlencode:(NSString *)string;


@end
