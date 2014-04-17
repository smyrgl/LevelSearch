//
//  TestDataManager.m
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import "TestDataManager.h"

@interface TestDataManager ()
{
    NSArray *_testNamesArray;
    NSArray *_testKeywordsArray;
}
@end

@implementation TestDataManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceQueue;
    static TestDataManager *testDataManager = nil;
    
    dispatch_once(&onceQueue, ^{ testDataManager = [[self alloc] init]; });
    return testDataManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"testNames" withExtension:@"json"]];
        NSData *adjectivesData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"adjectives" withExtension:@"json"]];
        _testNamesArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSAssert(!error, @"There should not be an error");
        _testKeywordsArray = [NSJSONSerialization JSONObjectWithData:adjectivesData options:NSJSONReadingAllowFragments error:&error];
        NSAssert(!error, @"There should not be an error");
    }
    return self;
}

- (NSString *)randomPersonName
{
    NSDictionary *randomPerson = _testNamesArray[arc4random_uniform((u_int32_t)[_testNamesArray count] - 1)];
    return randomPerson[@"name"];
}

- (NSString *)randomKeywords
{
    int count = arc4random_uniform(5) + 1;
    NSMutableString *keywords = [NSMutableString new];
    for (int i = 0; i < count; i++) {
        [keywords appendString:_testKeywordsArray[arc4random_uniform((u_int32_t)[_testKeywordsArray count] - 1)]];
        if (i < count) {
            [keywords appendString:@" "];
        }
    }
    
    return [NSString stringWithString:keywords];
}

@end
