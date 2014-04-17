//
//  XCTestCase+TestSetup.m
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/17/14.
//
//

#import "XCTestCase+TestSetup.h"

@implementation XCTestCase (TestSetup)

+ (void)setupTestCase
{
    [[LSIndex sharedIndex] purgeDiskIndex];
    [MagicalRecord setDefaultModelFromClass:[Person class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    [[LSIndex sharedIndex] addIndexingToEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]] forAttributes:@[@"name", @"keywords"]];
    [[LSIndex sharedIndex] startWatchingManagedObjectContext:[NSManagedObjectContext MR_rootSavingContext]];
    [[LSIndex sharedIndex] setDefaultQueryContext:[NSManagedObjectContext MR_rootSavingContext]];
}

+ (void)setupTestClass
{
    
}

+ (void)teardownTestCase
{
    [[LSIndex sharedIndex] stopWatchingManagedObjectContext:[NSManagedObjectContext MR_rootSavingContext]];
    [MagicalRecord cleanUp];
    [[LSIndex sharedIndex] purgeDiskIndex];
}

+ (void)teardownTestClass
{
    
}

@end
