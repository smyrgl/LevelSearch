//
//  LSStopwatch.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "LSStopwatch.h"
#import <mach/mach_time.h>

@interface LSStopwatch ()
@property (nonatomic, assign, readwrite, getter=isRunning) BOOL running;
@property (nonatomic, assign, readwrite) CGFloat recordedTime;
@end

@implementation LSStopwatch
{
    uint64_t _startTime;
    uint64_t _stopTime;
    mach_timebase_info_data_t _info;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.running = NO;
        mach_timebase_info(&_info);
    }
    return self;
}

- (void)start
{
    self.running = YES;
    _startTime = mach_absolute_time();
}

- (void)stop
{
    _stopTime = mach_absolute_time();
    self.running = NO;
}

- (CGFloat)recordedTime
{
    uint64_t elapsed = _stopTime - _startTime;
    uint64_t nanos = elapsed * _info.numer / _info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
}

@end
