//
//  LevelSearchIndexingTests.m
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/17/14.
//
//

#import <XCTest/XCTest.h>

@interface LevelSearchIndexingTests : XCTestCase

@end

@implementation LevelSearchIndexingTests

- (void)setUp
{
    [super setUp];
    [XCTestCase setupTestCase];
}

+ (void)setUp
{
    [super setUp];
    [XCTestCase setupTestClass];
}

- (void)tearDown
{
    [XCTestCase teardownTestCase];
    [super tearDown];
}

+ (void)tearDown
{
    [XCTestCase teardownTestClass];
    [super tearDown];
}

- (void)testStopWords
{
    // First verify that the token is created without the stop words
    
    [[LSIndex sharedIndex] setStopWords:[NSSet set]];
    Person *newPerson = [Person buildRandomPeople:1][0];
    newPerson.name = @"Randy";

    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LSIndexingDidFinishNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                                  }];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    NSSet *results = [[LSIndex sharedIndex] queryWithString:@"Randy"];
    
    XCTAssert(results, @"There must be a results set");
    XCTAssert(results.count == 1, @"There should be a single object in the results set");
    
    [[LSIndex sharedIndex] setStopWords:[NSSet setWithObject:@"Randy"]];
    [[LSIndex sharedIndex] purgeDiskIndex];
    
    Person *reloadedPerson = [Person MR_findFirst];
    XCTAssert([reloadedPerson.name isEqualToString:@"Randy"], @"This should be the same person we created earlier");
    
    [[LSIndex sharedIndex] indexEntities:[NSSet setWithObject:reloadedPerson] withCompletion:^{
        [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
    }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    results = [[LSIndex sharedIndex] queryWithString:@"Randy"];
    
    XCTAssert(results, @"There must be a results set");
    XCTAssert(results.count == 0, @"There should not be any results for the query");
}

- (void)testManuallyIndexEntities
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextWithStoreCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];
    Person *newPerson = [Person buildRandomPeople:1 inContext:context][0];
    [context MR_saveToPersistentStoreWithCompletion:nil];
    
    [self waitForTimeout:1];
    
    // First check to make sure the new person isn't in the index
    
    NSSet *results = [[LSIndex sharedIndex] queryWithString:newPerson.name];
    
    XCTAssert(results, @"There must be a results set");
    XCTAssert(results.count == 0, @"The results set should be empty");
    
    __weak typeof(self) weakSelf = self;
    
    [[LSIndex sharedIndex] indexEntities:[NSSet setWithObject:newPerson] withCompletion:^{
        [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
    }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    // Now re-run the query
    
    results = [[LSIndex sharedIndex] queryWithString:newPerson.name];
    
    XCTAssert(results, @"There must be a results set");
    XCTAssert(results.count == 1, @"The results set should have the new person");
}

- (void)testCleanupAndRestartIndexing
{
    
}

@end
