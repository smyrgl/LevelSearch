//
//  LSAppDelegate.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "LSAppDelegate.h"
#import "LSTestManager+FTS4PerformanceTests.h"
#import "LSTestManager+LevelSearchPerformanceTests.h"

@implementation LSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[LSTestManager sharedManager] setupWithTestMode:LSTestModeLevelSearch];
    [LSTestManager performLevelSearchPerformanceTests];
}

@end
