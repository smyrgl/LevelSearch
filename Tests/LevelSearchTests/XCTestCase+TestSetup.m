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
    [[LSIndex sharedIndex] purgeDiskIndex];
    [[LSIndex sharedIndex] stopWatchingManagedObjectContext:[NSManagedObjectContext MR_rootSavingContext]];
    [MagicalRecord cleanUp];
}

+ (void)teardownTestClass
{
    
}

- (void)buildSampleIndex
{
    [Person buildRandomPeople:10];
    
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LSIndexingDidFinishNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                                  }];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
}

@end
