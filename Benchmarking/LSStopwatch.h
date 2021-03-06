//
//  LSStopwatch.h
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSStopwatch : NSObject

@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

- (void)start;
- (void)stop;

- (CGFloat)recordedTime;

@end
