//
//  LSIndex.h
//  
//
//  Created by John Tumminaro on 4/13/14.
//
//

#import <Foundation/Foundation.h>

/**
 `LSIndex` represents the search index...
 
 ## Subclassing Notes
 
 This class is not designed to be subclassed.
 
 ## NSCoding Caveats
 
 When archived to disk the existing index queue is flushed and pending index operations are archived and then rebuilt.
 
 */

typedef void (^LSIndexQueryResultsBlock)(NSSet *results);
typedef void (^LSIndexEntitiesCompletionBlock)();

typedef NS_OPTIONS(NSUInteger, LSIndexQueryOptions) {
    LSIndexQueryOptionsDefault                 = 0,
    LSIndexQueryOptionsSpaceMeansOR            = 1 << 0
};

@protocol LSIndexDelegate;

@interface LSIndex : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy) NSSet *stopWords;
@property (nonatomic, weak) id<LSIndexDelegate>delegate;
@property (nonatomic, assign) NSUInteger cacheSizeInBytes;
@property (nonatomic, copy, readonly) NSSet *watchedContexts;
@property (nonatomic, weak) NSManagedObjectContext *defaultQueryContext;
@property (nonatomic, assign, readonly, getter=isIndexing) BOOL indexing;

+ (instancetype)sharedIndex;
+ (instancetype)indexWithName:(NSString *)name;

- (void)purgeDiskIndex;

- (void)addIndexingToEntity:(NSEntityDescription *)entity forAttributes:(NSArray *)attributes;
- (void)startWatchingManagedObjectContext:(NSManagedObjectContext *)context;
- (void)stopWatchingManagedObjectContext:(NSManagedObjectContext *)context;

- (void)indexEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion;

- (NSSet *)queryWithString:(NSString *)qString;
- (NSSet *)queryWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options;
- (NSSet *)queryWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options inContext:(NSManagedObjectContext *)context;

- (void)queryInBackgroundWithString:(NSString *)qString withResults:(LSIndexQueryResultsBlock)results;
- (void)queryInBackgroundWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options withResults:(LSIndexQueryResultsBlock)results;
- (void)queryInBackgroundWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options inContext:(NSManagedObjectContext *)context withResults:(LSIndexQueryResultsBlock)results;

@end

@protocol LSIndexDelegate <NSObject>

@optional

- (void)searchIndexDidStartIndexing:(LSIndex *)aIndex;
- (void)searchIndexDidFinishIndexing:(LSIndex *)aIndex;

@end

extern NSString * const LSIndexingDidStartNotification;
extern NSString * const LSIndexingDidFinishNotification;


