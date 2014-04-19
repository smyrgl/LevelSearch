//
//  LSTestManager+LevelSearchPerformanceTests.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "LSTestManager+LevelSearchPerformanceTests.h"

@implementation LSTestManager (LevelSearchPerformanceTests)

+ (void)performLevelSearchPerformanceTests
{
    NSUInteger createCount = 10000;
    
    [[LSIndex sharedIndex] stopWatchingManagedObjectContext:[NSManagedObjectContext MR_rootSavingContext]];
    DDLogInfo(@"Creating %lu books", createCount);
    NSArray *books = [Book createRandomBooks:createCount];
    NSSet *indexBooks = [NSSet setWithArray:books];
    DDLogInfo(@"Created %lu books", createCount);
    
    LSStopwatch *stopwatch = [LSStopwatch new];
    [stopwatch start];
    [[LSIndex sharedIndex] indexEntities:indexBooks
                          withCompletion:^{
                              [stopwatch stop];
                              DDLogInfo(@"Time to index %f seconds", [stopwatch recordedTime]);
                              Book *testBook = [Book MR_findFirst];
                              NSString *partialName = [testBook.name substringToIndex:5];
                              LSStopwatch *queryStopwatch = [LSStopwatch new];
                              [queryStopwatch start];
                              [[LSIndex sharedIndex] queryInBackgroundWithString:partialName
                                                                     withResults:^(NSSet *results) {
                                                                         [queryStopwatch stop];
                                                                         DDLogInfo(@"Results: %@", results);
                                                                         DDLogInfo(@"Time to query %f seconds", [queryStopwatch recordedTime]);
                                                                     }];
                          }];
}

+ (void)performLevelSearchQueryTestsWithObjects:(NSUInteger)numberOfObjects queryCount:(NSUInteger)queries;
{
    [[LSIndex sharedIndex] stopWatchingManagedObjectContext:[NSManagedObjectContext MR_rootSavingContext]];
    DDLogInfo(@"Creating %lu books", numberOfObjects);
    NSArray *books = [Book createRandomBooks:numberOfObjects];
    NSSet *indexBooks = [NSSet setWithArray:books];
    DDLogInfo(@"Created %lu books", numberOfObjects);
    
    [[LSIndex sharedIndex] indexEntities:indexBooks
                          withCompletion:^{
                              for (int x = 0; x < queries; x++) {
                                  NSString *query = LSGetRandomStringWithCharCount(3);
                                  LSStopwatch *queryStopwatch = [LSStopwatch new];
                                  [queryStopwatch start];
                                  [[LSIndex sharedIndex] queryInBackgroundWithString:query
                                                                         withResults:^(NSSet *results) {
                                                                             [queryStopwatch stop];
                                                                             DDLogInfo(@"Query time: %f seconds", [queryStopwatch recordedTime]);
                                                                         }];
                              }
                          }];

}

@end
