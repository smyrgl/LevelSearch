//
//  LSFTS4Manager.h
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSFTS4Manager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, copy) NSSet *stopWords;
@property (nonatomic, assign, readonly, getter=isIndexing) BOOL indexing;

- (void)addIndexingToEntity:(NSEntityDescription *)entity forAttributes:(NSArray *)attributes;
- (void)startWatchingDefaultContext;
- (void)stopWatchingDefaultContext;
- (void)indexEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion;

- (NSSet *)queryWithString:(NSString *)qString;

- (void)queryInBackgroundWithString:(NSString *)qString withResults:(LSIndexQueryResultsBlock)results;

@end

extern NSString * const LSFTS4IndexingDidStartNotification;
extern NSString * const LSFTS4IndexingDidFinishNotification;