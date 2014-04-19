//
//  Book+Factory.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "Book+Factory.h"
#import "TestDataManager.h"

@implementation Book (Factory)

+ (NSArray *)buildRandomBooks:(NSUInteger)count
{
    NSMutableArray *returnArray = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        Book *newBook = [Book MR_createEntity];
        newBook.name = [[TestDataManager sharedManager] randomPersonName];
        newBook.keywords = [[TestDataManager sharedManager] randomKeywords];
        [returnArray addObject:newBook];
    }
    
    return [NSArray arrayWithArray:returnArray];
}

+ (NSArray *)createRandomBooks:(NSUInteger)count
{
    NSArray *books = [Book buildRandomBooks:count];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return books;
}

@end
