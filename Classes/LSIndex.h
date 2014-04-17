//
//  LSIndex.h
//  
//
//  Created by John Tumminaro on 4/13/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 `LSIndex` is the primary class to manage your search index.  Each `LSIndex` instance represents a unique index with a matching LevelDB file so you can create many indexes or use the single shared index depending on your use case.
 
 ## NSCoding Support
 
 This class does not support `NSCoding` as it is not necessary to save your indexes directly.  When you request an index by name you will get back the matching disk index if it was previously created or a new LevelDB file will be created if none exist.  So you only need to persist the name of the index and then request it by name each time.
 
 */

typedef void (^LSIndexQueryResultsBlock)(NSSet *results);
typedef void (^LSIndexEntitiesCompletionBlock)();

typedef NS_OPTIONS(NSUInteger, LSIndexQueryOptions) {
    LSIndexQueryOptionsDefault                 = 0,
    LSIndexQueryOptionsSpaceMeansOR            = 1 << 0
};

@protocol LSIndexDelegate;

@interface LSIndex : NSObject

/**
 The name of the index.
 
 @warning `name` must not be `nil`.
 */

@property (nonatomic, copy, readonly) NSString *name;

/**
 A set of stop words for the index.  By default this is empty, but it is good practice to populate this with a set of stop words for the language you are using.
 */

@property (nonatomic, copy) NSSet *stopWords;

/**
 Size of the LRU cache used with the `LSIndex`.  Default value is 20 Megabytes but you are heavily encouraged to customize this to your particular needs.
 */

@property (nonatomic, assign) NSUInteger cacheSizeInBytes;

/**
 Readonly set of contexts currently being watching.
 */

@property (nonatomic, copy, readonly) NSSet *watchedContexts;

/**
 Default context used for querying.  This can be assigned to whatever you like (or done on a per-query basis using the appropriate query methods) but by default it will be set to the FIRST `NSManagedObjectContext` that you start watching.
 
 @warning `defaultQueryContext` cannot be `nil`.
 */

@property (nonatomic, weak) NSManagedObjectContext *defaultQueryContext;

/**
 Whether the index is currently performing indexing or not.
 */

@property (nonatomic, assign, readonly, getter=isIndexing) BOOL indexing;

/**
 Optional delegate which is informed when the indexer starts and stops indexing.
 */

@property (nonatomic, weak) id<LSIndexDelegate>delegate;

///---------------------
/// @name Initialization
///---------------------

/**
 Returns the default shared index.
 
 @return A default shared index for your application.
 */

+ (instancetype)sharedIndex;

/**
 Returns an index with the name provided.  If there is an existing index on disk with the name specified it is used, if not then a new index file is created.
 
 @param name The name of the index you wish to create.
 
 @return A default shared index for your application.
 */

+ (instancetype)indexWithName:(NSString *)name;

///-----------------------
/// @name Index Management
///-----------------------

/**
 Adds indexing to the provided attributes for the entity specified.  
 
 @param entity `NSEntityDescription` of the `NSManagedObject` you wish to index.
 @param attributes An array of strings with the name of the attributes you wish to index.
 
 @warning Attributes provided must be of `NSString` type on the model object.
 */

- (void)addIndexingToEntity:(NSEntityDescription *)entity forAttributes:(NSArray *)attributes;

/**
 Starts watching a given `NSManagedObjectContext`.
 
 @param context The `NSManagedObjectContext` you wish to watch.  If you specify a context that is already being watched then this method does nothing--it will not throw an exception.
 
 @warning You should only watch contexts that are directly tied to the `NSPersistentStoreCoordinator` as watching child contexts will not successfully index objects.  This is because the index does not support objects with temporary objectIDs as it uses the objectIDs as the key in the index.
 */

- (void)startWatchingManagedObjectContext:(NSManagedObjectContext *)context;

/**
 Stops watching a given `NSManagedObjectContext`.  If you specify a context that is not being watched then this method does nothing--it will not throw an exception.
 
 @param context The `NSManagedObjectContext` you wish to stop watching.
 */

- (void)stopWatchingManagedObjectContext:(NSManagedObjectContext *)context;

/**
 Manually indexes a set of `NSManagedObjects` and calls a completion block when finished.  This is useful for re-building indexes or adding indexing to an existing store.
 
 @param entities An `NSSet` containing the `NSManagedObjects` you wish to index.
 
 @warning You must call `addIndexingToEntity` before using this method or else it will not index the objects provided.
 */

- (void)indexEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion;

///--------------------------
/// @name Synchronous Queries
///--------------------------

/**
 ## Notes
 
 Although synchronous methods are provided, it is HIGHLY recommended that you use the async methods for most use cases.  Although search tends to be very fast it is not a good idea to build an auto-complete search which uses the synchronous calls as it will cause noticable typing lag.  The sync queries are useful for unit tests and specialized cases where you might want to manage your own query dispatch queues but they should not be called on the main thread unless you know full well what you are doing.
 */

/**
 Performs query with the provided string.
 
 @param qString String with the query you wish to perform.
 
 @return A set of `NSManagedObject` returned from a fetch request against the default query context using the default search options.
 */

- (NSSet *)queryWithString:(NSString *)qString;

/**
 Performs query with the provided string and options.
 
 @param qString String with the query you wish to perform.
 @param options Options for the search.
 
 @return A set of `NSManagedObject` returned from a fetch request against the default query context with the specified search options.
 
 @see LSIndexQueryOptions
 */

- (NSSet *)queryWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options;

/**
 Performs query with the provided string, options and context.
 
 @param qString String with the query you wish to perform.
 @param options Options for the search.
 @param context Context you wish to search against.
 
 @return A set of `NSManagedObject` returned from a fetch request against the provided context using the specified search options.
 
 @see LSIndexQueryOptions
 */

- (NSSet *)queryWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options inContext:(NSManagedObjectContext *)context;

///---------------------------
/// @name Asynchronous Queries
///---------------------------

/**
 ## Notes
 
 Async queries are performed against a serial dispatch queue so you will always get FIFO behavior appropriate for use in things like auto-complete.
 */

/**
 Performs a query in the background with the provided string.
 
 @param qString String with the query you wish to perform.
 @param results A block object executed when the query finished.  It has no return value and takes a single argument: a query response set containing the objects found during the query.
 
 @see LSIndexQueryResultsBlock
 */

- (void)queryInBackgroundWithString:(NSString *)qString withResults:(LSIndexQueryResultsBlock)results;

/**
 Performs a query in the background with the provided string and options.
 
 @param qString String with the query you wish to perform.
 @param options Options for the search.
 @param results A block object executed when the query finished.  It has no return value and takes a single argument: a query response set containing the objects found during the query.
 
 @see LSIndexQueryResultsBlock
 @see LSIndexQueryOptions
 */

- (void)queryInBackgroundWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options withResults:(LSIndexQueryResultsBlock)results;

/**
 Performs a query in the background with the provided string, options and context.
 
 @param qString String with the query you wish to perform.
 @param options Options for the search.
 @param context Context you wish to search against.
 @param results A block object executed when the query finished.  It has no return value and takes a single argument: a query response set containing the objects found during the query.
 
 @see LSIndexQueryResultsBlock
 @see LSIndexQueryOptions
 */

- (void)queryInBackgroundWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options inContext:(NSManagedObjectContext *)context withResults:(LSIndexQueryResultsBlock)results;

///------------------------------
/// @name Index Utility Functions
///------------------------------

/**
 Blocking call that clears all keys from the given index.
 */

- (void)purgeDiskIndex;

@end

///-----------------------------
/// @name Index Delegate Methods
///-----------------------------

@protocol LSIndexDelegate <NSObject>

@optional

/**
 Called when an index starts indexing.
 
 @param aIndex The index that has started indexing.
 */

- (void)searchIndexDidStartIndexing:(LSIndex *)aIndex;

/**
 Called when an index finishes indexing.
 
 @param aIndex The index that has finished indexing.
 */

- (void)searchIndexDidFinishIndexing:(LSIndex *)aIndex;

@end

///--------------------
/// @name Notifications
///--------------------

/**
 Posted when an index begins indexing with the index as the provided object in the notification.
 */

extern NSString * const LSIndexingDidStartNotification;

/**
 Posted when an index finishes indexing with the index as the provided object in the notification.
 */

extern NSString * const LSIndexingDidFinishNotification;


