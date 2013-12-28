//
//  main.m
//  BaconBarHelper
//
//  Created by Thomas Buck on 28.12.13.
//  Copyright (c) 2013 xythobuz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[])
{
    AppDelegate *delegate = [[AppDelegate alloc] init];
    [[NSApplication sharedApplication] setDelegate:delegate];
    [NSApp run];
    return 0;
}
