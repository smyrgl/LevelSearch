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

static NSString * const LSIndexCacheSizeSetting = @"LSIndexCacheSizeSetting";
static NSString * const LSIndexNameSetting = @"LSIndexNameSetting";

static NSString * const kIndexedEntitiesKey = @"LevelSearchIndexedEntitiesKey";

NSString * const LSIndexingDidStartNotification = @"com.tinylittlegears.levelsearch.index.indexing.start";
NSString * const LSIndexingDidFinishNotification = @"com.tinylittlegears.levelsearch.index.indexing.finish";

static NSUInteger const kDefaultCacheSizeInBytes = 1048576 * 20;

static dispatch_queue_t level_search_clear_indexing_queue() {
    static dispatch_queue_t level_search_clear_indexing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        level_search_clear_indexing_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.index.clearIndexQueue", NULL);
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
        level_search_indexing_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.index.indexingQueue", NULL);
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

@property (atomic, strong) LevelDB *indexDB;
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
        index = [[self alloc] initWithSettings:@{LSIndexCacheSizeSetting: [NSNumber numberWithInteger:kDefaultCacheSizeInBytes], LSIndexNameSetting: @"shared"}];
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
        self.indexDB = [LevelDB databaseInLibraryWithName:self.name andOptions:options];
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

    @autoreleasepool {
        NSArray *wordsAndEmptyStrings = [qString.lowercaseString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        
        NSMutableSet *matchingIDs;
        
        if (options & LSIndexQueryOptionsSpaceMeansOR) {
            
            matchingIDs = [NSMutableSet new];
            
            NSMutableArray *subpredicates = [NSMutableArray new];
            
            for (NSString *qSubstring in words) {
                NSPredicate *subpredicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@", qSubstring];
                [subpredicates addObject:subpredicate];
            }
            
            NSPredicate *finalPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates];
            
            [self.indexDB enumerateKeysAndObjectsUsingBlock:^(LevelDBKey *key, id value, BOOL *stop) {
                if ([finalPredicate evaluateWithObject:NSStringFromLevelDBKey(key)]) {
                    [matchingIDs addObjectsFromArray:[value allObjects]];
                }
            }];
            
        } else {
            
            NSMutableSet *resultSet = [NSMutableSet new];
            for (NSString *word in words) {
                NSMutableSet *wordResultSet = [NSMutableSet new];
                [self.indexDB enumerateKeysAndObjectsUsingBlock:^(LevelDBKey *key, id value, BOOL *stop) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@", word];
                    if ([predicate evaluateWithObject:NSStringFromLevelDBKey(key)]) {
                        [wordResultSet addObjectsFromArray:[value allObjects]];
                    }
                }];
                [resultSet addObject:wordResultSet];
            }
            for (NSMutableSet *wordResultSet in resultSet) {
                if (!matchingIDs) {
                    matchingIDs = wordResultSet;
                } else {
                    [matchingIDs intersectSet:wordResultSet];
                }
            }
        }
        
        NSMutableSet *returnSet = [NSMutableSet new];
        
        for (NSString *value in matchingIDs) {
            NSManagedObjectID *objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:value]];
            NSManagedObject *object = [context existingObjectWithID:objectID error:nil];
            [returnSet addObject:object];
        }
        
        return [NSSet setWithSet:returnSet];
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
    
    NSSet *clearObjects = [[NSSet setWithSet:[userInfo objectForKey:NSUpdatedObjectsKey]] setByAddingObjectsFromSet:[userInfo objectForKey:NSDeletedObjectsKey]];
    NSSet *indexObjects = [[NSSet setWithSet:[userInfo objectForKey:NSInsertedObjectsKey]] setByAddingObjectsFromSet:[userInfo objectForKey:NSUpdatedObjectsKey]];
    
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

- (void)clearIndexForEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion
{
    @autoreleasepool {
        LDBWritebatch *deleteBatch = [self.indexDB newWritebatch];
        
        __weak typeof(self) weakSelf = self;
        
        for (NSManagedObject *clearObject in entities) {
            dispatch_group_async(level_search_clear_indexing_group(), level_search_clear_indexing_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSString *pk = clearObject.objectID.URIRepresentation.absoluteString;
                [strongSelf.indexDB enumerateKeysAndObjectsUsingBlock:^(LevelDBKey *key, id value, BOOL *stop) {
                    NSSet *valueSet = value;
                    if ([valueSet containsObject:pk]) {
                        NSMutableSet *newSet = [NSMutableSet setWithSet:valueSet];
                        [newSet removeObject:pk];
                        [deleteBatch setObject:[NSSet setWithSet:newSet] forKey:NSStringFromLevelDBKey(key)];
                    }
                }];
            });
        }
        
        dispatch_group_notify(level_search_clear_indexing_group(), level_search_clear_indexing_queue(), ^{
            [deleteBatch apply];
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
            if (indexObject.objectID.isTemporaryID == NO) {
                dispatch_group_async(level_search_indexing_group(), level_search_indexing_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if ([strongSelf.indexedEntities valueForKey:indexObject.entity.name]) {
                        for (NSString *attribute in (NSArray *)[strongSelf.indexedEntities valueForKey:indexObject.entity.name]) {
                            NSString *value = [indexObject valueForKey:attribute];
                            NSSet *tokenizedAttribute = [strongSelf tokenizeString:value];
                            for (NSString *token in tokenizedAttribute) {
                                NSMutableSet *valueSet = [NSMutableSet setWithSet:[self.indexDB valueForKey:token]];
                                [valueSet addObject:indexObject.objectID.URIRepresentation.absoluteString];
                                [strongSelf.indexDB setObject:[NSSet setWithSet:valueSet] forKey:token];
                            }
                        }
                    }
                });
            }
        }
        
        dispatch_group_notify(level_search_indexing_group(), level_search_indexing_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }
}


@end
