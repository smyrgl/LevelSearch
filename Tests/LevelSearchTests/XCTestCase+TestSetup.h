//
//  XCTestCase+TestSetup.h
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/17/14.
//
//

#import <XCTest/XCTest.h>

@interface XCTestCase (TestSetup)

+ (void)setupTestCase;
+ (void)setupTestClass;
+ (void)teardownTestCase;
+ (void)teardownTestClass;

- (void)buildSampleIndex;

@end
