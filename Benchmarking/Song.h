//
//  Song.h
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/20/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * album;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * popularity;

@end
