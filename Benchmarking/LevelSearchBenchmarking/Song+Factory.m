//
//  Song+Factory.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/20/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "Song+Factory.h"
#import <MessagePack.h>

@implementation Song (Factory)

+ (void)createNumberOfSongs:(NSUInteger)number
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"songs" ofType:nil];
    NSData *songsData = [NSData dataWithContentsOfFile:path];
    NSArray *songs = [songsData messagePackParse];
    
    if (songs.count < number) {
        number = songs.count;
    }
    
    for (int i = 0; i < number; i++) {
        NSDictionary *songDict = songs[i];
        Song *newSong = [Song MR_createEntity];
        newSong.id = songDict[@"id"];
        newSong.artist = songDict[@"artist_name"];
        newSong.popularity = [NSNumber numberWithDouble:[songDict[@"artist_popularity"] doubleValue]];
        newSong.album = songDict[@"release"];
        newSong.title = songDict[@"title"];
    }
}

@end
