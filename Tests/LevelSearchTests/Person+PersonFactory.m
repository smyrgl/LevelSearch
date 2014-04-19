//
//  Person+PersonFactory.m
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import "Person+PersonFactory.h"
#import "TestDataManager.h"

@implementation Person (PersonFactory)

+ (NSArray *)buildRandomPeople:(NSUInteger)count
{
    return [Person buildRandomPeople:count inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray *)createRandomPeople:(NSUInteger)count
{
    return [Person createRandomPeople:count inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray *)buildRandomPeople:(NSUInteger)count inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *returnArray = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        Person *newPerson = [Person MR_createInContext:context];
        newPerson.age = [NSNumber numberWithInteger:[Person randomAge]];
        newPerson.balanceInAccount = [Person randomBalance];
        newPerson.birthdate = [Person randomBirthdate];
        newPerson.married = [NSNumber numberWithBool:[Person randomBool]];
        newPerson.mileTimeInSeconds = [NSNumber numberWithDouble:[Person randomMileTimeInSeconds]];
        newPerson.name = [[TestDataManager sharedManager] randomPersonName];
        newPerson.numberOfWives = [NSNumber numberWithInteger:[Person randomNumberOfWives]];
        newPerson.parents = [Person randomParentsDictionary];
        newPerson.personID = [NSNumber numberWithUnsignedLongLong:[Person randomPersonID]];
        newPerson.tvTimePerYearInSeconds = [NSNumber numberWithFloat:[Person randomTVTimePerYearInSeconds]];
        newPerson.keywords = [[TestDataManager sharedManager] randomKeywords];
        [returnArray addObject:newPerson];
    }
    
    return [NSArray arrayWithArray:returnArray];
}

+ (NSArray *)createRandomPeople:(NSUInteger)count inContext:(NSManagedObjectContext *)context
{
    NSArray *people = [Person buildRandomPeople:count inContext:context];
    [context MR_saveToPersistentStoreAndWait];
    return people;
}

#pragma mark - Private

+ (NSUInteger)randomAge
{
    return arc4random_uniform(100) + 1;
}

+ (NSDecimalNumber *)randomBalance
{
    srand48(time(0));
    double r = drand48() + 0.01;
    r = r * (arc4random_uniform(1000) + 1);
    
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithDecimal:[NSNumber numberWithDouble:r].decimalValue];
    return [number decimalNumberByRoundingAccordingToBehavior:handler];
}

+ (NSDate *)randomBirthdate
{
    NSInteger secondsFromNow = arc4random_uniform(86400 * 365 * 90);
    return [NSDate dateWithTimeIntervalSinceNow:-secondsFromNow];
}

+ (BOOL)randomBool
{
    int tmp = (arc4random() % 30)+1;
    if(tmp % 5 == 0)
        return YES;
    return NO;
}

+ (double)randomMileTimeInSeconds
{
    srand48(time(0));
    double r = drand48();
    
    return r * (arc4random_uniform(600) + 360);
}

+ (NSString *)randomName
{
    return @"John";
}

+ (NSUInteger)randomNumberOfWives
{
    return arc4random_uniform(100000);
}

+ (NSDictionary *)randomParentsDictionary
{
    NSMutableDictionary *parentsDict = [NSMutableDictionary new];
    [parentsDict setObject:@"Joe" forKey:@"dad"];
    [parentsDict setObject:@"Carol" forKey:@"mom"];
    return [NSDictionary dictionaryWithDictionary:parentsDict];
}

+ (u_int64_t)randomPersonID
{
    u_int64_t random = (((uint64_t) rand() <<  0) & 0x000000000000FFFFull) |
    (((uint64_t) rand() << 16) & 0x00000000FFFF0000ull) |
    (((uint64_t) rand() << 32) & 0x0000FFFF00000000ull) |
    (((uint64_t) rand() << 48) & 0xFFFF000000000000ull);
    
    return random;
}

+ (float)randomTVTimePerYearInSeconds
{
    srand48(time(0));
    double r = drand48();
    
    return r * (arc4random_uniform(600) + 360);
}

@end
