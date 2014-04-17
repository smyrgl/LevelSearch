//
//  LevelSearchSetupTests.m
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import <XCTest/XCTest.h>
#import <LevelDB.h>

@interface LevelSearchSetupTests : XCTestCase

@end

@implementation LevelSearchSetupTests

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

- (void)testSharedIndex
{
    LSIndex *sharedIndex = [LSIndex sharedIndex];
    XCTAssert(sharedIndex, @"There must be a shared index");
    
    LevelDB *db = [sharedIndex valueForKey:@"indexDB"];
    XCTAssert(db, @"There must be a LevelDB for the shared index");
    XCTAssert([[db allKeys] count] == 0, @"The shared index DB should be empty");
}

- (void)testNamedIndex
{
    LSIndex *namedIndex = [LSIndex indexWithName:@"newIndex"];
    XCTAssert(namedIndex, @"There must be a named index");
    
    LevelDB *db = [namedIndex valueForKey:@"indexDB"];
    XCTAssert(db, @"There must be a LevelDB for the named index");
    XCTAssert([[db allKeys] count] == 0, @"The named index DB should be empty");
}

- (void)testPurgeDiskIndex
{
    LSIndex *sharedIndex = [LSIndex sharedIndex];
    XCTAssert(sharedIndex, @"There must be a shared index");
    
    LevelDB *db = [sharedIndex valueForKey:@"indexDB"];
    XCTAssert(db, @"There must be a LevelDB for the shared index");
    XCTAssert([[db allKeys] count] == 0, @"The shared index DB should be empty");

    [Person buildRandomPeople:10];
    
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LSIndexingDidFinishNotification
                                                      object:sharedIndex
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf notify:XCTAsyncTestCaseStatusSucceeded];
                                                  }];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:nil];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:2];
    
    XCTAssert([[db allKeys] count] > 0, @"There must be keywords in the index");
    
    [[LSIndex sharedIndex] purgeDiskIndex];
    
    XCTAssert([[db allKeys] count] == 0, @"The index must be cleared of all keys");
}

@end
