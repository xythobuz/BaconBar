/*
 * StateModel.m
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
#import "StateModel.h"

@implementation StateModel

@synthesize username, modhash, useSubscriptions, subreddits, length, showSubreddit;

-(void)registerDefaultPreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"username"];
    [appDefaults setValue:@"" forKey:@"modhash"];
    [appDefaults setValue:[NSNumber numberWithBool:YES] forKey:@"subscriptions"];
    [appDefaults setValue:[NSNumber numberWithInt:10] forKey:@"length"];
    [appDefaults setValue:[NSNumber numberWithBool:YES] forKey:@"showSubs"];
    [appDefaults setValue:@"" forKey:@"session"];
    [store registerDefaults:appDefaults];
}

-(void)savePreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    [store setObject:username forKey:@"username"];
    [store setObject:modhash forKey:@"modhash"];
    [store setBool:useSubscriptions forKey:@"subscriptions"];
    [store setObject:subreddits forKey:@"subreddits"];
    [store setInteger:length forKey:@"length"];
    [store setBool:showSubreddit forKey:@"showSubs"];
    [store synchronize];
}

-(void)loadPreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    [store synchronize];
    username = [store stringForKey:@"username"];
    modhash = [store stringForKey:@"modhash"];
    useSubscriptions = [store boolForKey:@"subscriptions"];
    subreddits = [store arrayForKey:@"subreddits"];
    length = [store integerForKey:@"length"];
    showSubreddit = [store boolForKey:@"showSubs"];
}

@end
