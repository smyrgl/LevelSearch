//
//  LSUtilityFunctions.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#include <sys/sysctl.h>
#import <mach/mach_time.h>

uint8_t LSCountOfCores(void)
{
    NSUInteger ncpu;
    size_t len = sizeof(ncpu);
    sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
    
    return ncpu;
}

NSString *LSAppDataDirectory(void)
{
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    
    NSArray *possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL *appSupportDir = nil;
    NSURL *appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    if (appSupportDir) {
        NSString *executableName = [[[NSBundle mainBundle] executablePath] lastPathComponent];
        appDirectory = [appSupportDir URLByAppendingPathComponent:executableName];
        return [appDirectory path];
    }
    
    return nil;
}

CGFloat LSTimedBlock (void (^block)(void))
{
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;
    
    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;
    
    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
}

NSString *LSGetRandomStringWithCharCount(int count)
{
    NSMutableString *randomString = [NSMutableString new];
    for (int x = 0; x < count; x++) {
        [randomString appendString:[NSString stringWithFormat:@"%c", arc4random_uniform(26) + 'a']];
    }
    return [NSString stringWithString:randomString];
}