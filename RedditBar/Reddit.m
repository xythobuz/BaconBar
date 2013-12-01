//
//  Reddit.m
//  RedditBar
//
//  Created by Thomas Buck on 01.12.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import "Reddit.h"

@implementation Reddit

NSString *version = @"1.0.0";
NSString *author = @"xythobuz";
NSString *appName = @"RedditBar";

@synthesize username, modhash, password;

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

-(id)initWithUsername:(NSString *)name Modhash:(NSString *)hash {
    self = [super init];
    if (self) {
        username = name;
        modhash = hash;
        password = nil;
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
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    NSString *requestBodyLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestBodyData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ssl.reddit.com/api/login"]];
    [request setTimeoutInterval:5.0];
    [request setCachePolicy:NSURLCacheStorageNotAllowed];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:requestBodyLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"%@/%@ by %@", appName, version, author] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBodyData];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil) {
        return nil;
    } else {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        long code = [resp statusCode];
        if (code == 200) {
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

-(BOOL)isAuthenticated {
    return FALSE;
}

@end
