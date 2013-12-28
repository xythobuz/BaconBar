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
#import <ServiceManagement/ServiceManagement.h>

@implementation StateModel

@synthesize username, modhash, useSubscriptions, subreddits, length, showSubreddit, titleLength, refreshInterval, filter, removeVisited, reloadAfterVisit, lastNotifiedPM, startOnLogin;

NSString *s_username = @"username";
NSString *s_modhash = @"modhash";
NSString *s_useSubs = @"subscriptions";
NSString *s_subreddits = @"subreddits";
NSString *s_length = @"length";
NSString *s_subs = @"showSubs";
NSString *s_title = @"titleLength";
NSString *s_refresh = @"refreshInterval";
NSString *s_filter = @"filter";
NSString *s_remove = @"remove";
NSString *s_reload = @"reload";
NSString *s_lastPM = @"lastNotifiedPM";
NSString *s_startLogin = @"startOnLogin";

-(void)registerDefaultPreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionaryWithObject:@"" forKey:s_username];
    [appDefaults setValue:@"" forKey:s_modhash];
    [appDefaults setValue:[NSNumber numberWithBool:YES] forKey:s_useSubs];
    [appDefaults setValue:[NSNumber numberWithInt:10] forKey:s_length];
    [appDefaults setValue:[NSNumber numberWithBool:YES] forKey:s_subs];
    [appDefaults setValue:[NSNumber numberWithInt:66] forKey:s_title];
    [appDefaults setValue:[NSNumber numberWithInt:5] forKey:s_refresh];
    [appDefaults setValue:@"hot" forKey:s_filter];
    [appDefaults setValue:[NSNumber numberWithBool:YES] forKey:s_remove];
    [appDefaults setValue:[NSNumber numberWithBool:YES] forKey:s_reload];
    [appDefaults setValue:@"" forKey:s_lastPM];
    [appDefaults setValue:[NSNumber numberWithBool:NO] forKey:s_startLogin];
    [store registerDefaults:appDefaults];
}

-(void)savePreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    [store setObject:username forKey:s_username];
    [store setObject:modhash forKey:s_modhash];
    [store setBool:useSubscriptions forKey:s_useSubs];
    [store setObject:subreddits forKey:s_subreddits];
    [store setInteger:length forKey:s_length];
    [store setBool:showSubreddit forKey:s_subs];
    [store setInteger:titleLength forKey:s_title];
    [store setInteger:refreshInterval forKey:s_refresh];
    [store setObject:filter forKey:s_filter];
    [store setBool:removeVisited forKey:s_remove];
    [store setBool:reloadAfterVisit forKey:s_reload];
    [store setObject:lastNotifiedPM forKey:s_lastPM];
    
    [store synchronize];
    
    // TODO start on login on or off
    if (startOnLogin != [store boolForKey:s_startLogin]) {
        NSString *appName = [NSString stringWithFormat:@"%@Helper", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
        if (SMLoginItemSetEnabled((__bridge CFStringRef)appName, startOnLogin)) {
            [store setBool:startOnLogin forKey:s_startLogin];
        }
    }
}

-(void)loadPreferences {
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    [store synchronize];
    username = [store stringForKey:s_username];
    modhash = [store stringForKey:s_modhash];
    useSubscriptions = [store boolForKey:s_useSubs];
    subreddits = [store arrayForKey:s_subreddits];
    length = [store integerForKey:s_length];
    showSubreddit = [store boolForKey:s_subs];
    titleLength = [store integerForKey:s_title];
    refreshInterval = [store integerForKey:s_refresh];
    filter = [store stringForKey:s_filter];
    removeVisited = [store boolForKey:s_remove];
    reloadAfterVisit = [store boolForKey:s_reload];
    lastNotifiedPM = [store stringForKey:s_lastPM];
    startOnLogin = [store boolForKey:s_startLogin];
}

@end
