//
//  LSTestManager.h
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LSTestMode) {
    LSTestModeLevelSearch,
    LSTestModeCoreData,
    LSTestModeFTS4,
    LSTestModeSearchKit,
    LSTestModeRestKit
};

@interface LSTestManager : NSObject

@property (nonatomic, assign, readonly) LSTestMode currentMode;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

+ (instancetype)sharedManager;

- (void)setupWithTestMode:(LSTestMode)mode;
- (void)resetTesting;

- (void)runPerformanceTestsWithNumberOfObjects:(NSUInteger)objects numberOfQueries:(NSUInteger)queries;

@end

extern NSString * const kPathForSqliteDB;
