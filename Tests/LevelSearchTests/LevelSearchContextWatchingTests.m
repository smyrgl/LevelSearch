//
//  LevelSearchContextWatchingTests.m
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import <XCTest/XCTest.h>
#import <LevelDB.h>

@interface LevelSearchContextWatchingTests : XCTestCase

@end

@implementation LevelSearchContextWatchingTests

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

- (void)testSingleEntity
{
    Person *person = [Person buildRandomPeople:1][0];
    XCTAssert(person, @"Must be a person object");
    XCTAssert([Person MR_countOfEntities] == 1, @"There must be a single Person saved in Core Data");
    
    NSString *searchString;
    
    if (person.name.length > 5) {
        searchString = [person.name substringToIndex:5];
    } else {
        searchString = [person.name copy];
    }
    
    XCTAssert(searchString, @"There must be a search string");
    XCTAssert(searchString.length > 0, @"The search string must be longer than 0");
    
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LSIndexingDidFinishNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                                  }];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:nil];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    NSSet *results = [[LSIndex sharedIndex] queryWithString:searchString];
    XCTAssert(results.count == 1, @"There must be a single returned result for the search string");
    XCTAssert([[results anyObject] isKindOfClass:[Person class]], @"The returned result must be a person");
    XCTAssert([[[results anyObject] valueForKey:@"objectID"] isEqual:person.objectID], @"The returned result must be the created person");
}

- (void)testMultipleEntities
{
    [Person createRandomPeople:500];
    
    NSSet *results = [[LSIndex sharedIndex] queryWithString:@"c"];
    XCTAssert(results, @"There must be results");
}

- (void)testStopWatchingContext
{
    NSManagedObjectContext *newContext = [NSManagedObjectContext MR_contextWithStoreCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];
    [[LSIndex sharedIndex] startWatchingManagedObjectContext:newContext];
    LevelDB *db = [[LSIndex sharedIndex] valueForKey:@"indexDB"];
    
    // Verify that the new context is being watched
    
    XCTAssert([[[LSIndex sharedIndex] watchedContexts] containsObject:newContext], @"The index watched contexts should contain the new context");
    [Person buildRandomPeople:10 inContext:newContext];
    
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LSIndexingDidFinishNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                                  }];
    
    [newContext MR_saveOnlySelfWithCompletion:nil];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    NSUInteger numberOfKeys = [[db allKeys] count];
    
    // Stop watching context
    
    [[LSIndex sharedIndex] stopWatchingManagedObjectContext:newContext];
    
    [Person buildRandomPeople:10 inContext:newContext];
    
    [newContext MR_saveOnlySelfWithCompletion:nil];
    
    [self waitForTimeout:1];
    
    XCTAssert(numberOfKeys == [[db allKeys] count], @"The number of keys in the index should not have changed since the watching stopped");
}

- (void)testStartWatchingContext
{
    NSManagedObjectContext *newContext = [NSManagedObjectContext MR_contextWithStoreCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];
    [[LSIndex sharedIndex] startWatchingManagedObjectContext:newContext];
    XCTAssert([[[LSIndex sharedIndex] watchedContexts] containsObject:newContext], @"The index watched contexts should contain the new context");
    LevelDB *db = [[LSIndex sharedIndex] valueForKey:@"indexDB"];
    XCTAssert([[db allKeys] count] == 0, @"There should be no keys in the index");
    
    [Person buildRandomPeople:10 inContext:newContext];
    
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LSIndexingDidFinishNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                                  }];
    
    [newContext MR_saveOnlySelfWithCompletion:nil];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    XCTAssert([[db allKeys] count] > 0, @"There should be keys in the index now");
}

@end
