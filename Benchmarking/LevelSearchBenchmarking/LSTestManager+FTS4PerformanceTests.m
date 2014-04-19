//
//  LSTestManager+FTS4PerformanceTests.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "LSTestManager+FTS4PerformanceTests.h"
#import "LSFTS4Manager.h"

@implementation LSTestManager (FTS4PerformanceTests)

+ (void)performFTS4PerformanceTests
{
    NSUInteger createCount = 10000;
    
    [[LSFTS4Manager sharedManager] stopWatchingDefaultContext];
    DDLogInfo(@"Creating %lu books", createCount);
    NSArray *books = [Book createRandomBooks:createCount];
    NSSet *indexBooks = [NSSet setWithArray:books];
    DDLogInfo(@"Created %lu books", createCount);
    
    LSStopwatch *stopwatch = [LSStopwatch new];
    [stopwatch start];
    [[LSFTS4Manager sharedManager] indexEntities:indexBooks withCompletion:^{
        [stopwatch stop];
        DDLogInfo(@"Time to index %f seconds", [stopwatch recordedTime]);
        NSString *pathToDB = [NSString stringWithFormat:@"%@%@", LSAppDataDirectory(), kPathForSqliteDB];
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:pathToDB error:nil];
        DDLogInfo(@"Index disk size is %llu", (unsigned long long)attributes[NSFileSize]);
        Book *testBook = [Book MR_findFirst];
        NSString *partialName = [testBook.name substringToIndex:5];
        LSStopwatch *queryStopwatch = [LSStopwatch new];
        [queryStopwatch start];
        [[LSFTS4Manager sharedManager] queryInBackgroundWithString:partialName
                                                       withResults:^(NSSet *results) {
                                                           [queryStopwatch stop];
                                                           DDLogInfo(@"Results: %@", results);
                                                           DDLogInfo(@"Time to query %f seconds", [queryStopwatch recordedTime]);
                                                       }];

    }];
}

@end
