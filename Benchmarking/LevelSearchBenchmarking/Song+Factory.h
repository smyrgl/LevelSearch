//
//  Song+Factory.h
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/20/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "Song.h"

@interface Song (Factory)

+ (void)createNumberOfSongs:(NSUInteger)number;

@end
