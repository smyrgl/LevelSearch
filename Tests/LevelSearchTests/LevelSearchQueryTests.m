//
//  LevelSearchQueryTests.m
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/17/14.
//
//

#import <XCTest/XCTest.h>

@interface LevelSearchQueryTests : XCTestCase

@end

@implementation LevelSearchQueryTests

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

- (void)testSyncQuery
{
    [self buildSampleIndex];
    Person *person = [Person MR_findFirst];
    
    NSSet *results = [[LSIndex sharedIndex] queryWithString:person.name];
    
    XCTAssert(results, @"There must be a results set returned");
    XCTAssert(results.count == 1, @"There must be a single result returned");
}

- (void)testEmptySyncQuery
{
    NSSet *results = [[LSIndex sharedIndex] queryWithString:@"a"];
    XCTAssert(results, @"There must be a results set returned");
    XCTAssert(results.count == 0, @"The results set should be empty");
}

- (void)testNotFoundSyncQuery
{
    [self buildSampleIndex];
    NSSet *results = [[LSIndex sharedIndex] queryWithString:@"lkajdasldjlaskdjlasjdalsjd"];
    XCTAssert(results, @"There must be a results set returned");
    XCTAssert(results.count == 0, @"The results set should be empty");
}

- (void)testSyncQuerySpaceMeansOR
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

    NSArray *peopleArray = [Person MR_findAll];
    Person *personOne = peopleArray[0];
    Person *personTwo = peopleArray[1];
    
    NSSet *results = [[LSIndex sharedIndex] queryWithString:[NSString stringWithFormat:@"%@ %@", personOne.name, personTwo.name] withOptions:LSIndexQueryOptionsSpaceMeansOR];
    
    XCTAssert(results, @"There must be a results set");
    XCTAssert(results.count == 2, @"There must be two results");
    
    for (Person *resultsPerson in results) {
        XCTAssert([resultsPerson.objectID isEqual:personOne.objectID] || [resultsPerson.objectID isEqual:personTwo.objectID], @"The object IDs must be of the two people queried");
    }
}

- (void)testSyncQuerySpaceMeansAND
{
    [self buildSampleIndex];
    NSArray *peopleArray = [Person MR_findAll];
    Person *personOne = peopleArray[0];
    Person *personTwo = peopleArray[1];

    NSSet *results = [[LSIndex sharedIndex] queryWithString:[NSString stringWithFormat:@"%@ %@", personOne.name, personTwo.name]];
    
    XCTAssert(results, @"There must be a results set");
    XCTAssert(results.count == 0, @"There must be zero results");
    
    NSString *partialName = [personOne.name substringWithRange:NSMakeRange(0, 2)];
    NSString *partialKeyword = [personOne.keywords substringWithRange:NSMakeRange(0, 3)];
    NSSet *partialResults = [[LSIndex sharedIndex] queryWithString:[NSString stringWithFormat:@"%@ %@", partialName, partialKeyword]];
    
    XCTAssert(partialResults, @"There must be a results set");
    XCTAssert(partialResults.count == 1, @"There must be a single result");
    
    Person *resultPerson = [partialResults anyObject];
    XCTAssert([resultPerson.objectID isEqual:personOne.objectID], @"The result person must have the same objectID as personOne");
}

- (void)testSyncQueryContext
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextWithStoreCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];
    [[LSIndex sharedIndex] startWatchingManagedObjectContext:context];
    [Person buildRandomPeople:1 inContext:context];
    
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LSIndexingDidFinishNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                                  }];
    
    [context MR_saveToPersistentStoreWithCompletion:nil];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    Person *person = [Person MR_findFirstInContext:context];
    
    XCTAssert(person, @"There must be a person");
    
    NSSet *results = [[LSIndex sharedIndex] queryWithString:person.name withOptions:LSIndexQueryOptionsDefault inContext:context];
    
    XCTAssert(results, @"There must be a set returned for the proper context query");
    XCTAssert([results count] == 1, @"The proper context should have a single result");
    
    Person *queryPerson = [results anyObject];
    XCTAssert([queryPerson.objectID isEqual:person.objectID], @"The objectID of the person returned in the query matches that of the created person");
}

- (void)testAsyncQuery
{
    [self buildSampleIndex];
    Person *person = [Person MR_findFirst];
    
    __block NSSet *queryResults;
    __weak typeof(self) weakSelf = self;
    
    [[LSIndex sharedIndex] queryInBackgroundWithString:person.name
                                           withResults:^(NSSet *results) {
                                               queryResults = results;
                                               [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                           }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    XCTAssert(queryResults, @"There must be a results set returned");
    XCTAssert(queryResults.count == 1, @"There must be a single result returned");
}

- (void)testAsyncQuerySpaceMeansOR
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
    
    NSArray *peopleArray = [Person MR_findAll];
    Person *personOne = peopleArray[0];
    Person *personTwo = peopleArray[1];
    NSString *query = [NSString stringWithFormat:@"%@ %@", personOne.name, personTwo.name];
    
    __block NSSet *queryResults;
    
    [[LSIndex sharedIndex] queryInBackgroundWithString:query
                                           withOptions:LSIndexQueryOptionsSpaceMeansOR
                                           withResults:^(NSSet *results) {
                                               queryResults = results;
                                               [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                           }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    XCTAssert(queryResults, @"There must be a results set returned");
    XCTAssert(queryResults.count == 2, @"There must be two results returned");
    
    for (Person *resultsPerson in queryResults) {
        XCTAssert([resultsPerson.objectID isEqual:personOne.objectID] || [resultsPerson.objectID isEqual:personTwo.objectID], @"The object IDs must be of the two people queried");
    }
}

- (void)testAsyncQuerySpaceMeansAND
{
    [self buildSampleIndex];
    NSArray *peopleArray = [Person MR_findAll];
    Person *personOne = peopleArray[0];
    Person *personTwo = peopleArray[1];
    NSString *partialName = [personOne.name substringWithRange:NSMakeRange(0, 4)];
    NSString *partialKeyword = [personOne.keywords substringWithRange:NSMakeRange(0, 3)];
    NSString *badQuery = [NSString stringWithFormat:@"%@ %@", personOne.name, personTwo.name];
    NSString *goodQuery = [NSString stringWithFormat:@"%@ %@", partialName, partialKeyword];
    
    __block NSSet *badQueryResults;
    __block NSSet *goodQueryResults;
    
    __weak typeof(self) weakSelf = self;
    
    [[LSIndex sharedIndex] queryInBackgroundWithString:badQuery
                                           withOptions:LSIndexQueryOptionsDefault
                                           withResults:^(NSSet *results) {
                                               badQueryResults = results;
                                               [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                           }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    XCTAssert(badQueryResults, @"There must be a results set");
    XCTAssert(badQueryResults.count == 0, @"There must be zero results");
    
    [[LSIndex sharedIndex] queryInBackgroundWithString:goodQuery
                                           withOptions:LSIndexQueryOptionsDefault
                                           withResults:^(NSSet *results) {
                                               goodQueryResults = results;
                                               [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                           }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    XCTAssert(goodQueryResults, @"There must be a results set");
    XCTAssert(goodQueryResults.count == 1, @"There must be a single result");
    
    Person *resultPerson = [goodQueryResults anyObject];
    XCTAssert([resultPerson.objectID isEqual:personOne.objectID], @"The result person must have the same objectID as personOne");
}

- (void)testAsyncQueryContext
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextWithStoreCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];
    [[LSIndex sharedIndex] startWatchingManagedObjectContext:context];
    [Person buildRandomPeople:1 inContext:context];
    
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LSIndexingDidFinishNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                                  }];
    
    [context MR_saveToPersistentStoreWithCompletion:nil];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    Person *person = [Person MR_findFirstInContext:context];
    
    XCTAssert(person, @"There must be a person");
    
    __block NSSet *queryResults;
    
    [[LSIndex sharedIndex] queryInBackgroundWithString:person.name
                                           withOptions:LSIndexQueryOptionsDefault
                                             inContext:context
                                           withResults:^(NSSet *results) {
                                               queryResults = results;
                                               [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                           }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    XCTAssert(queryResults, @"There must be a set returned for the proper context query");
    XCTAssert([queryResults count] == 1, @"The proper context should have a single result");
    
    Person *queryPerson = [queryResults anyObject];
    XCTAssert([queryPerson.objectID isEqual:person.objectID], @"The objectID of the person returned in the query matches that of the created person");
}

- (void)testQueryWithEmptyString
{
    [self buildSampleIndex];
    NSSet *results = [[LSIndex sharedIndex] queryWithString:@""];
    XCTAssert(results, @"There should be a results set returned");
    XCTAssert(results.count == 0, @"Results set should be empty");
}

- (void)testQueryWithWhitespace
{
    [self buildSampleIndex];
    NSSet *results = [[LSIndex sharedIndex] queryWithString:@"    "];
    XCTAssert(results, @"There should be a results set returned");
    XCTAssert(results.count == 0, @"Results set should be empty");
}

@end
