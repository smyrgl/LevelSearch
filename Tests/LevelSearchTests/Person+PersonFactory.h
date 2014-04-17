//
//  Person+PersonFactory.h
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import "Person.h"

@interface Person (PersonFactory)

+ (NSArray *)buildRandomPeople:(NSUInteger)count;
+ (NSArray *)createRandomPeople:(NSUInteger)count;

+ (NSArray *)buildRandomPeople:(NSUInteger)count inContext:(NSManagedObjectContext *)context;
+ (NSArray *)createRandomPeople:(NSUInteger)count inContext:(NSManagedObjectContext *)context;

@end
