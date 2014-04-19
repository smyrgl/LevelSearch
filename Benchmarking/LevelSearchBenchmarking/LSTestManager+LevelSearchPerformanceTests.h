//
//  LSTestManager+LevelSearchPerformanceTests.h
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "LSTestManager.h"

@interface LSTestManager (LevelSearchPerformanceTests)

+ (void)performLevelSearchPerformanceTests;

+ (void)performLevelSearchQueryTestsWithObjects:(NSUInteger)numberOfObjects queryCount:(NSUInteger)queries;

@end
