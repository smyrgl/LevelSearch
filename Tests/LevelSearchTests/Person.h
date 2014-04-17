//
//  Person.h
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString *keywords;
@property (nonatomic, retain) NSDate * birthdate;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * numberOfWives;
@property (nonatomic, retain) NSNumber * married;
@property (nonatomic, retain) NSNumber * personID;
@property (nonatomic, retain) NSDecimalNumber * balanceInAccount;
@property (nonatomic, retain) NSNumber * mileTimeInSeconds;
@property (nonatomic, retain) NSNumber * tvTimePerYearInSeconds;
@property (nonatomic, retain) NSData * avatar;
@property (nonatomic, retain) id parents;

@end
