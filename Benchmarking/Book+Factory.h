//
//  Book+Factory.h
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "Book.h"

@interface Book (Factory)

+ (void)createNumberOfBooks:(NSUInteger)number;

@end
