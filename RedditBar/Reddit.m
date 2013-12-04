//
//  Reddit.m
//  RedditBar
//
//  Created by Thomas Buck on 01.12.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import "Reddit.h"
#import "AppDelegate.h"

@implementation Reddit

NSString *version = @"1.0.0";
NSString *author = @"xythobuz";
NSString *appName = @"RedditBar";

NSInteger maxTitleLength = 50;
NSString *replaceTextForTitle = @"...";

@synthesize username, modhash, password, length, subreddits;

-(id)initWithUsername:(NSString *)name Modhash:(NSString *)hash Length:(NSInteger)leng {
    self = [super init];
    if (self) {
        username = name;
        modhash = hash;
        password = nil;
        length = leng;
    }
    return self;
}

-(id)initWithUsername:(NSString *)name Password:(NSString *)pass {
    self = [super init];
    if (self) {
        username = name;
        modhash = nil;
        password = pass;
    }
    return self;
}

-(NSString *)queryModhash {
    NSMutableString *stringData = [NSMutableString stringWithString:@"api_type=json"];
    [stringData appendFormat:@"&user=%@", [self urlencode: username]];
    [stringData appendFormat:@"&passwd=%@", [self urlencode: password]];
    [stringData appendString:@"&rem=True"];
    NSHTTPURLResponse *response;
    NSData *data = [self queryAPI:@"api/login" withData:stringData andResponse:&response];
    if (data == nil) {
        return nil;
    } else {
        long code = [response statusCode];
        if (code == 200) {
            NSError *error;
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error)
                return nil;
            if([object isKindOfClass:[NSDictionary class]]) {
                NSDictionary *results = object;
                NSDictionary *json = [results valueForKey:@"json"];
                if (json == nil)
                    return nil;
                NSDictionary *data = [json valueForKey:@"data"];
                if (data == nil)
                    return nil;
                return [data valueForKey:@"modhash"];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }
}

-(NSArray *)convertJSONToItemArray:(NSData *)data {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSDictionary *dat = [json valueForKey:@"data"];
    if (dat == nil)
        return nil;
    NSArray *children = [dat valueForKey:@"children"];
    if (children == nil)
        return nil;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[children count]];
    for (NSUInteger i = 0; i < [children count]; i++) {
        NSDictionary *child = [children objectAtIndex:i];
        NSDictionary *current = [child valueForKey:@"data"];
        NSString *name = [current valueForKey:@"title"];
        NSString *link = [current valueForKey:@"url"];
        NSString *comments = nil;
        NSNumber *num = [current valueForKey:@"is_self"];
        BOOL isSelf = [num boolValue];
        if (!isSelf) {
            comments = [NSString stringWithFormat:@"http://www.reddit.com%@", [current valueForKey:@"permalink"]];
        }
        if ([name length] > maxTitleLength) {
            name = [NSString stringWithFormat:@"%@%@", [name substringToIndex:(maxTitleLength - [replaceTextForTitle length])], replaceTextForTitle];
        }
        RedditItem *r = [RedditItem itemWithName:name Link:link Comments:comments Self:isSelf];
        [r setFullName:[current valueForKey:@"title"]];
        [array insertObject:r atIndex:i];
    }
    return array;
}

-(void)readFrontpage:(id)parent {
    NSHTTPURLResponse *response;
    NSString *url = [NSString stringWithFormat:@"hot.json?limit=%ld", (long)length];
    NSData *data = [self queryAPI:url withResponse:&response];
    if ((data == nil) || ([response statusCode] != 200)) {
        [parent performSelectorOnMainThread:@selector(reloadListHasFrontpageCallback:) withObject:nil waitUntilDone:false];
    } else {
        [parent performSelectorOnMainThread:@selector(reloadListHasFrontpageCallback:) withObject:[self convertJSONToItemArray:data] waitUntilDone:false];
    }
}

-(void)readSubreddits:(id)parent {
    // TODO read subreddits (as multireddit?)
    // TODO if implemented, enable checkbox in prefs
}

-(void)isAuthenticatedNewModhash:(id)parent {
    NSHTTPURLResponse *response;
    NSData *data = [self queryAPI:@"api/me.json" withResponse:&response];
    if ((data != nil) && ([response statusCode] == 200)) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSDictionary *data = [json valueForKey:@"data"];
        if (data == nil) {
            [parent performSelectorOnMainThread:@selector(reloadListNotAuthenticatedCallback) withObject:nil waitUntilDone:false];
            return;
        }
        NSString *newHash = [data valueForKey:@"modhash"];
        if ((newHash == nil) || ([newHash isEqualToString:@""])) {
            [parent performSelectorOnMainThread:@selector(reloadListNotAuthenticatedCallback) withObject:nil waitUntilDone:false];
            return;
        }
        if (![newHash isEqualToString:modhash]) {
            modhash = newHash;
        }
        [parent performSelectorOnMainThread:@selector(reloadListIsAuthenticatedCallback) withObject:nil waitUntilDone:false];
        return;
        
    }
    [parent performSelectorOnMainThread:@selector(reloadListNotAuthenticatedCallback) withObject:nil waitUntilDone:false];
}

-(NSData *)queryAPI:(NSString *)api withResponse:(NSHTTPURLResponse **)res {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getAPIPoint:api]];
    [request setTimeoutInterval:5.0];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%@/%@ by %@", appName, version, author] forHTTPHeaderField:@"User-Agent"];
    if ((modhash != nil) && (![modhash isEqualToString:@""]))
        [request addValue:modhash forHTTPHeaderField:@"X-Modhash"];
    [request setHTTPMethod:@"GET"];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:res error:&error];
    if (error)
        return nil;
    else
        return data;
}

-(NSData *)queryAPI:(NSString *)api withData:(NSString *)string andResponse:(NSHTTPURLResponse **)res {
    NSData *requestBodyData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *requestBodyLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestBodyData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self getAPIPoint:api]];
    [request setTimeoutInterval:5.0];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:requestBodyLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"%@/%@ by %@", appName, version, author] forHTTPHeaderField:@"User-Agent"];
    if ((modhash != nil) && (![modhash isEqualToString:@""]))
        [request addValue:modhash forHTTPHeaderField:@"X-Modhash"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBodyData];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:res error:&error];
    if (error)
        return nil;
    else
        return data;
}

-(NSURL *)getAPIPoint:(NSString *)where {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://ssl.reddit.com/%@", where]];
}

-(NSString *)urlencode:(NSString *)string {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; i++) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
