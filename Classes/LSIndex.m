//
//  LSIndex.m
//  
//
//  Created by John Tumminaro on 4/13/14.
//
//

#import "LSIndex.h"
#import <LevelDB.h>
#import <LDBWriteBatch.h>
#import <MessagePack/MessagePack.h>

static NSString * const LSIndexCacheSizeSetting = @"LSIndexCacheSizeSetting";
static NSString * const LSBloomFilterSizeSetting = @"LSBloomFilterSizeSetting";
static NSString * const LSIndexNameSetting = @"LSIndexNameSetting";

static NSString * const kIndexedEntitiesKey = @"LevelSearchIndexedEntitiesKey";

NSString * const LSIndexingDidStartNotification = @"com.tinylittlegears.levelsearch.index.indexing.start";
NSString * const LSIndexingDidFinishNotification = @"com.tinylittlegears.levelsearch.index.indexing.finish";

static int const kDefaultCacheSizeInBytes = 1048576 * 10;
static int const kDefaultBloomFilterSizeInBits = 10;


NSString * LSExecutableName(void)
{
    NSString *executableName = [[[NSBundle mainBundle] executablePath] lastPathComponent];
    if (nil == executableName) {
        executableName = @"LevelSearch";
    }
    
    return executableName;
}

NSString * LSPathToIndex(void)
{
#if TARGET_OS_IPHONE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
#else
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    
    NSArray *possibleURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory
                                             inDomains:NSUserDomainMask];
    NSURL *appSupportDir = nil;
    NSURL *appDirectory = nil;
    
    if ([possibleURLs count] >= 1) {
        appSupportDir = [possibleURLs objectAtIndex:0];
    }
    
    if (appSupportDir) {
        appDirectory = [appSupportDir URLByAppendingPathComponent:LSExecutableName()];
        return [appDirectory path];
    }
    return nil;
#endif
}

static dispatch_queue_t level_search_clear_indexing_queue() {
    static dispatch_queue_t level_search_clear_indexing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        level_search_clear_indexing_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.index.clearIndexQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return level_search_clear_indexing_queue;
}

static dispatch_group_t level_search_clear_indexing_group() {
    static dispatch_group_t level_search_clear_indexing_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        level_search_clear_indexing_group = dispatch_group_create();
    });
    
    return level_search_clear_indexing_group;
}

static dispatch_queue_t level_search_indexing_queue() {
    static dispatch_queue_t level_search_indexing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        level_search_indexing_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.index.indexingQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return level_search_indexing_queue;
}

static dispatch_group_t level_search_indexing_group() {
    static dispatch_group_t level_search_indexing_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        level_search_indexing_group = dispatch_group_create();
    });
    
    return level_search_indexing_group;
}

static dispatch_queue_t level_search_query_queue() {
    static dispatch_queue_t level_search_query_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        level_search_query_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.index.queryQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return level_search_query_queue;
}

@interface LSIndex ()

@property (nonatomic, strong) LevelDB *indexDB;
@property (nonatomic, strong) NSMutableDictionary *indexedEntities;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, assign, readwrite, getter=isIndexing) BOOL indexing;

@end

@implementation LSIndex
{
    NSMutableSet *_internalWatchedContexts;
}

#pragma mark - Lifecycle

+ (instancetype)sharedIndex
{
    static dispatch_once_t onceQueue;
    static LSIndex *index = nil;
    
    dispatch_once(&onceQueue, ^{
        index = [[self alloc] initWithSettings:@{LSIndexCacheSizeSetting: [NSNumber numberWithInteger:kDefaultCacheSizeInBytes], LSIndexNameSetting: @"shared", LSBloomFilterSizeSetting: [NSNumber numberWithInteger:kDefaultBloomFilterSizeInBits]}];
    });
    return index;
}

+ (instancetype)indexWithName:(NSString *)name
{
    NSAssert(name, @"You must provide a name for the index or use the shared index");
    
    LSIndex *index = [[self alloc] initWithSettings:@{LSIndexCacheSizeSetting: [NSNumber numberWithInteger:kDefaultCacheSizeInBytes], LSIndexNameSetting: name}];
    
    return index;
}

- (instancetype)initWithSettings:(NSDictionary *)settings
{
    self = [super init];
    if (self) {
        self.name = settings[LSIndexNameSetting];
        _cacheSizeInBytes = kDefaultCacheSizeInBytes;
        LevelDBOptions options = [LevelDB makeOptions];
        options.cacheSize = [settings[LSIndexCacheSizeSetting] integerValue];
        options.filterPolicy = [settings[LSBloomFilterSizeSetting] intValue];
        self.indexDB = [[LevelDB alloc] initWithPath:[NSString stringWithFormat:@"%@/levelsearch/%@", LSPathToIndex(), self.name] name:self.name andOptions:options];
        self.indexDB.safe = NO;
        
        self.indexDB.decoder = ^(LevelDBKey *key, NSData *data)
        {
            return [NSSet setWithArray:[data messagePackParse]];
        };
        
        self.indexDB.encoder = ^(LevelDBKey *key, id object)
        {
            return [[object allObjects] messagePack];
        };
        
        self.indexedEntities = [NSMutableDictionary new];
        self.indexing = NO;
        _internalWatchedContexts = [NSMutableSet new];
    }
    return self;
}

- (void)dealloc
{
    [self.indexDB close];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getters

- (NSSet *)watchedContexts
{
    return [NSSet setWithSet:_internalWatchedContexts];
}

#pragma mark - Setters

- (void)setDefaultQueryContext:(NSManagedObjectContext *)defaultQueryContext
{
    NSParameterAssert(defaultQueryContext);
    _defaultQueryContext = defaultQueryContext;
}

- (void)setCacheSizeInBytes:(NSUInteger)cacheSizeInBytes
{
    _cacheSizeInBytes = cacheSizeInBytes;
    LevelDBOptions options = [LevelDB makeOptions];
    options.cacheSize = cacheSizeInBytes;
    [self.indexDB close];
    self.indexDB = [LevelDB databaseInLibraryWithName:self.name andOptions:options];
}

- (void)setIndexing:(BOOL)indexing
{
    if (indexing == YES && _indexing == NO) {
        _indexing = indexing;
        if ([self.delegate respondsToSelector:@selector(searchIndexDidStartIndexing:)]) {
            [self.delegate searchIndexDidStartIndexing:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:LSIndexingDidStartNotification object:self];
    } else if (indexing == NO && _indexing == YES) {
        _indexing = indexing;
        if ([self.delegate respondsToSelector:@selector(searchIndexDidFinishIndexing:)]) {
            [self.delegate searchIndexDidFinishIndexing:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:LSIndexingDidFinishNotification object:self];
    }
}

- (void)setStopWords:(NSSet *)stopWords
{
    _stopWords = [stopWords valueForKeyPath:@"lowercaseString"];
}

#pragma mark - Actions

- (void)purgeDiskIndex
{
    [self.indexDB removeAllObjects];
}

- (void)addIndexingToEntity:(NSEntityDescription *)entity forAttributes:(NSArray *)attributes
{
    NSParameterAssert(entity);
    NSParameterAssert(attributes);
    
    for (NSString *attributeName in attributes) {
        NSAttributeDescription *description = entity.attributesByName[attributeName];
        NSAssert(description.attributeType == NSStringAttributeType, @"Indexed attributes must be of NSString type");
    }
    
    [self.indexedEntities setValue:attributes forKey:entity.name];
}

- (void)startWatchingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSParameterAssert(context);
    
    if (!self.defaultQueryContext) {
        self.defaultQueryContext = context;
    }
    
    if (![_internalWatchedContexts containsObject:context]) {
        [_internalWatchedContexts addObject:context];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleContextDidSaveNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:context];
    }
}

- (void)stopWatchingManagedObjectContext:(NSManagedObjectContext *)context
{
    NSParameterAssert(context);
    
    if ([_internalWatchedContexts containsObject:context]) {
        [_internalWatchedContexts removeObject:context];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:context];
    }
}

#pragma mark - Indexing

- (void)indexEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion
{
    NSParameterAssert(entities);
    
    if (entities.count > 0) {
        self.indexing = YES;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self clearIndexForEntities:entities withCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf buildIndexForEntities:entities
                           withCompletion:^{
                               strongSelf.indexing = NO;
                               if (completion) {
                                   completion();
                               }
                           }];
    }];
}

#pragma mark - Query methods

- (NSSet *)queryWithString:(NSString *)qString
{
    NSParameterAssert(qString);
    NSAssert(self.defaultQueryContext, @"There is no default query context set, did you forget to start monitoring a managed object context?");
    
    return [self queryWithString:qString withOptions:LSIndexQueryOptionsDefault inContext:self.defaultQueryContext];
}

- (NSSet *)queryWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options
{
    NSParameterAssert(qString);
    NSAssert(self.defaultQueryContext, @"There is no default query context set, did you forget to start monitoring a managed object context?");
    
    return [self queryWithString:qString withOptions:options inContext:self.defaultQueryContext];
}

- (NSSet *)queryWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options inContext:(NSManagedObjectContext *)context
{
    NSParameterAssert(qString);
    NSParameterAssert(context);
    
    if (!qString) {
        return [NSSet set];
    }

    @autoreleasepool {
        
        NSSet *querySet = [self tokenizeString:qString];
        
        if (querySet.count == 0) {
            return [NSSet set];
        }
        
        NSMutableSet *matchingIDs = [NSMutableSet new];
        
        for (NSString *queryWord in querySet) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@", queryWord];
            if (options & LSIndexQueryOptionsSpaceMeansOR || matchingIDs.count == 0) {
                [self.indexDB enumerateKeysUsingBlock:^(LevelDBKey *key, BOOL *stop) {
                    if ([predicate evaluateWithObject:NSStringFromLevelDBKey(key)]) {
                        [matchingIDs unionSet:[self.indexDB objectForKey:NSStringFromLevelDBKey(key)]];
                    }
                }];
            } else {
                NSMutableSet *newSet = [NSMutableSet new];
                [self.indexDB enumerateKeysUsingBlock:^(LevelDBKey *key, BOOL *stop) {
                    [newSet unionSet:[self.indexDB objectForKey:NSStringFromLevelDBKey(key)]];
                }];
                [matchingIDs intersectSet:newSet];
            }
        }
        
        NSMutableSet *returnSet = [NSMutableSet new];
        
        for (NSString *pk in matchingIDs) {
            NSManagedObjectID *objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:pk]];
            NSManagedObject *object = [context existingObjectWithID:objectID error:nil];
            [returnSet addObject:object];
        }
        
        return returnSet;
    }
}

#pragma mark - Async Query Methods

- (void)queryInBackgroundWithString:(NSString *)qString withResults:(LSIndexQueryResultsBlock)results
{
    NSAssert(self.defaultQueryContext, @"There is no default query context set, did you forget to start monitoring a managed object context?");
    [self queryInBackgroundWithString:qString withOptions:LSIndexQueryOptionsDefault inContext:self.defaultQueryContext withResults:results];
}

- (void)queryInBackgroundWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options withResults:(LSIndexQueryResultsBlock)results
{
    NSAssert(self.defaultQueryContext, @"There is no default query context set, did you forget to start monitoring a managed object context?");
    [self queryInBackgroundWithString:qString withOptions:options inContext:self.defaultQueryContext withResults:results];
}

- (void)queryInBackgroundWithString:(NSString *)qString withOptions:(LSIndexQueryOptions)options inContext:(NSManagedObjectContext *)context withResults:(LSIndexQueryResultsBlock)results
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(level_search_query_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSSet *resultSet = [strongSelf queryWithString:qString withOptions:options inContext:context];
        if (results) {
            results(resultSet);
        }
    });    
}

#pragma mark - Core Data Save Notifications

- (void)handleContextDidSaveNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSSet *clearObjects = [[NSSet setWithSet:[userInfo objectForKey:NSDeletedObjectsKey]] setByAddingObjectsFromSet:[userInfo objectForKey:NSUpdatedObjectsKey]];
    clearObjects = [self objectsWithCandidates:clearObjects];
    NSSet *indexObjects = [[NSSet setWithSet:[userInfo objectForKey:NSInsertedObjectsKey]] setByAddingObjectsFromSet:[userInfo objectForKey:NSUpdatedObjectsKey]];
    indexObjects = [self objectsWithCandidates:indexObjects];
    
    __weak typeof(self) weakSelf = self;
    
    if (clearObjects.count > 0 || indexObjects.count > 0) {
        self.indexing = YES;
    }

    [self clearIndexForEntities:clearObjects withCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf buildIndexForEntities:indexObjects
                           withCompletion:^{
                               strongSelf.indexing = NO;
                           }];
    }];
}

#pragma mark - Private

- (NSSet *)tokenizeString:(NSString *)string
{
    if (!string || string.length == 0) {
        return [NSSet set];
    } else {
        NSMutableSet *tokens = [NSMutableSet set];
        
        CFLocaleRef locale = CFLocaleCopyCurrent();
        
        NSString *tokenizeText = string = [string stringByFoldingWithOptions:kCFCompareCaseInsensitive|kCFCompareDiacriticInsensitive locale:[NSLocale systemLocale]];
        CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, (__bridge CFStringRef)tokenizeText, CFRangeMake(0, CFStringGetLength((__bridge CFStringRef)tokenizeText)), kCFStringTokenizerUnitWord, locale);
        CFStringTokenizerTokenType tokenType = kCFStringTokenizerTokenNone;
        
        while (kCFStringTokenizerTokenNone != (tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer))) {
            CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
            
            NSRange range = NSMakeRange(tokenRange.location, tokenRange.length);
            NSString *token = [string substringWithRange:range];
            
            [tokens addObject:token];
        }
        
        CFRelease(tokenizer);
        CFRelease(locale);
        
        if (self.stopWords) [tokens minusSet:self.stopWords];
        
        return tokens;
    }
}

- (NSString *)buildTokenizedString:(NSArray *)tokens
{
    if (tokens.count == 0) {
        return nil;
    }
    NSMutableString *returnString = [NSMutableString new];
    
    for (NSString *token in tokens) {
        [returnString appendFormat:@"%@ ", token];
    }
    
    [returnString deleteCharactersInRange:NSMakeRange(returnString.length - 1, 1)];
    return [NSString stringWithString:returnString];
}

- (NSSet *)objectsWithCandidates:(NSSet *)candidates
{
    NSMutableSet *returnSet = [NSMutableSet new];
    for (NSManagedObject *object in candidates) {
        if (self.indexedEntities[object.entity.name] && !object.objectID.isTemporaryID) {
            [returnSet addObject:object];
        }
    }
    return [NSSet setWithSet:returnSet];
}

- (void)clearIndexForEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion
{
    @autoreleasepool {
        __weak typeof(self) weakSelf = self;
        for (NSManagedObject *clearObject in entities) {
            dispatch_group_async(level_search_clear_indexing_group(), level_search_clear_indexing_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                LDBWritebatch *writeBatch = [strongSelf.indexDB newWritebatch];
                NSString *pk = clearObject.objectID.URIRepresentation.absoluteString;
                [strongSelf.indexDB enumerateKeysAndObjectsUsingBlock:^(LevelDBKey *key, id value, BOOL *stop) {
                    if ([value containsObject:pk]) {
                        NSMutableSet *mutableSet = [NSMutableSet setWithSet:value];
                        [mutableSet removeObject:pk];
                        [writeBatch setObject:[NSSet setWithSet:mutableSet] forKey:NSStringFromLevelDBKey(key)];
                    }
                }];
                [writeBatch apply];
            });
        }
        
        dispatch_group_notify(level_search_clear_indexing_group(), level_search_clear_indexing_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }
}

- (void)buildIndexForEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion
{
    @autoreleasepool {
        __weak typeof(self) weakSelf = self;
        for (NSManagedObject *indexObject in entities) {
            dispatch_group_async(level_search_indexing_group(), level_search_indexing_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                LDBWritebatch *writeBatch = [strongSelf.indexDB newWritebatch];
                NSMutableSet *indexWords = [NSMutableSet new];
                for (NSString *attribute in (NSArray *)strongSelf.indexedEntities[indexObject.entity.name]) {
                    NSString *value = [indexObject valueForKey:attribute];
                    [indexWords unionSet:[self tokenizeString:value]];
                }
                
                for (NSString *indexWord in indexWords) {
                    NSSet *currentObjects = [strongSelf.indexDB objectForKey:indexWord];
                    if (currentObjects) {
                        NSMutableSet *newSet = [NSMutableSet setWithSet:currentObjects];
                        [newSet addObject:indexObject.objectID.URIRepresentation.absoluteString];
                        [writeBatch setObject:newSet forKey:indexWord];
                    } else {
                        [writeBatch setObject:[NSSet setWithObject:indexObject.objectID.URIRepresentation.absoluteString] forKey:indexWord];
                    }
                }
                [writeBatch apply];
            });
        }
        
        dispatch_group_notify(level_search_indexing_group(), level_search_indexing_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }
}


@end
