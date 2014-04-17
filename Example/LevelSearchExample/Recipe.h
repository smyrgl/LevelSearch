//
//  Recipe.h
//  LevelSearchExample
//
//  Created by John Tumminaro on 4/13/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Recipe : NSManagedObject

@property (nonatomic, retain) NSString * ingredients;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * recipeDescription;

@end
