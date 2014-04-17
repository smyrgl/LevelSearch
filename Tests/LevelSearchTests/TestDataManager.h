//
//  TestDataManager.h
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import <Foundation/Foundation.h>

@interface TestDataManager : NSObject

+ (instancetype)sharedManager;

- (NSString *)randomPersonName;
- (NSString *)randomKeywords;

@end
