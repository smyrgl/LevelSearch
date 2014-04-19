//
//  LSFTS4Manager.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "LSFTS4Manager.h"

NSString * LSFTS4IndexName(NSString *object, NSString *attribute)
{
    return [NSString stringWithFormat:@"%@%@", object, attribute];
}

static dispatch_queue_t fts4_search_clear_indexing_queue() {
    static dispatch_queue_t fts4_search_clear_indexing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fts4_search_clear_indexing_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.fts4test.index.clearIndexQueue", NULL);
    });
    
    return fts4_search_clear_indexing_queue;
}

static dispatch_group_t fts4_search_clear_indexing_group() {
    static dispatch_group_t fts4_search_clear_indexing_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fts4_search_clear_indexing_group = dispatch_group_create();
    });
    
    return fts4_search_clear_indexing_group;
}

static dispatch_queue_t fts4_search_update_indexing_queue() {
    static dispatch_queue_t fts4_search_update_indexing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fts4_search_update_indexing_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.fts4test.index.updateIndexQueue", NULL);
    });
    
    return fts4_search_update_indexing_queue;
}

static dispatch_group_t fts4_search_update_indexing_group() {
    static dispatch_group_t fts4_search_update_indexing_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fts4_search_update_indexing_group = dispatch_group_create();
    });
    
    return fts4_search_update_indexing_group;
}


static dispatch_queue_t fts4_search_indexing_queue() {
    static dispatch_queue_t fts4_search_indexing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fts4_search_indexing_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.fts4test.index.indexingQueue", NULL);
    });
    
    return fts4_search_indexing_queue;
}

static dispatch_group_t fts4_search_indexing_group() {
    static dispatch_group_t fts4_search_indexing_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fts4_search_indexing_group = dispatch_group_create();
    });
    
    return fts4_search_indexing_group;
}

static dispatch_queue_t fts4_search_query_queue() {
    static dispatch_queue_t fts4_search_query_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fts4_search_query_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.fts4test.index.queryQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return fts4_search_query_queue;
}

NSString * const LSFTS4IndexingDidStartNotification = @"com.tinylittlegears.levelsearch.fts4test.indexing.start";
NSString * const LSFTS4IndexingDidFinishNotification = @"com.tinylittlegears.levelsearch.fts4test.indexing.finished";

@interface LSFTS4Manager ()
@property (nonatomic, strong) NSMutableDictionary *indexedEntities;
@property (nonatomic, strong) NSMutableDictionary *indexes;
@property (nonatomic, assign, readwrite, getter=isIndexing) BOOL indexing;
@end

@implementation LSFTS4Manager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceQueue;
    static LSFTS4Manager *ftsManager = nil;
    
    dispatch_once(&onceQueue, ^{ ftsManager = [[self alloc] init]; });
    return ftsManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.indexedEntities = [NSMutableDictionary new];
        self.indexes = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setIndexing:(BOOL)indexing
{
    if (indexing == YES && _indexing == NO) {
        _indexing = indexing;
        [[NSNotificationCenter defaultCenter] postNotificationName:LSFTS4IndexingDidFinishNotification object:self];
    } else if (indexing == NO && _indexing == YES) {
        _indexing = indexing;
        [[NSNotificationCenter defaultCenter] postNotificationName:LSFTS4IndexingDidStartNotification object:self];
    }
}


- (void)addIndexingToEntity:(NSEntityDescription *)entity forAttributes:(NSArray *)attributes
{
    for (NSString *attributeName in attributes) {
        [[LSTestManager sharedManager].dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeUpdate:[NSString stringWithFormat:@"CREATE VIRTUAL TABLE IF NOT EXISTS %@ USING fts4(name, contents);", LSFTS4IndexName(entity.name, attributeName)]];
        }];
        [self.indexes setObject:LSFTS4IndexName(entity.name, attributeName) forKey:entity.name];
        NSAttributeDescription *description = entity.attributesByName[attributeName];
        NSAssert(description.attributeType == NSStringAttributeType, @"Indexed attributes must be of NSString type");
    }
    
    [self.indexedEntities setValue:attributes forKey:entity.name];
}

- (void)startWatchingDefaultContext
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleContextDidSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[NSManagedObjectContext MR_rootSavingContext]];
}

- (void)stopWatchingDefaultContext
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleContextDidSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[NSManagedObjectContext MR_rootSavingContext]];
}

- (void)indexEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion
{
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

- (NSSet *)queryWithString:(NSString *)qString
{
    NSString *query = [self queryStringFromInput:qString];
    
    NSMutableSet *returnSet = [NSMutableSet new];

    for (NSString *indexName in [self.indexes allValues]) {
        NSString *fullQueryString = [NSString stringWithFormat:@"SELECT name FROM %@ WHERE %@ MATCH '\"%@\"'", indexName, indexName, query];
        __block FMResultSet *results;
        [[[LSTestManager sharedManager] dbQueue] inDatabase:^(FMDatabase *db) {
            results = [db executeQuery:fullQueryString];
        }];
        
        while ([results next]) {
            NSString *pk = [results stringForColumn:@"name"];
            NSManagedObjectID *objectID = [[[NSManagedObjectContext MR_defaultContext] persistentStoreCoordinator] managedObjectIDForURIRepresentation:[NSURL URLWithString:pk]];
            NSManagedObject *object = [[NSManagedObjectContext MR_defaultContext] existingObjectWithID:objectID error:nil];
            [returnSet addObject:object];
        }
        
        [results close];
    }
    
    return [NSSet setWithSet:returnSet];
}

- (void)queryInBackgroundWithString:(NSString *)qString withResults:(LSIndexQueryResultsBlock)results
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(fts4_search_query_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSSet *resultSet = [strongSelf queryWithString:qString];
        if (results) {
            results(resultSet);
        }
    });
}

#pragma mark - Core Data Save Notifications

- (void)handleContextDidSaveNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSSet *deleteObjects = [self objectsWithCandidates:userInfo[NSDeletedObjectsKey]];
    NSSet *updateObjects = [self objectsWithCandidates:userInfo[NSUpdatedObjectsKey]];
    NSSet *indexObjects = [self objectsWithCandidates:userInfo[NSInsertedObjectsKey]];
    
    __weak typeof(self) weakSelf = self;
    
    if (deleteObjects.count > 0 || updateObjects.count > 0 || indexObjects.count > 0) {
        self.indexing = YES;
    }
    
    [self clearIndexForEntities:deleteObjects withCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateIndexForEntities:updateObjects
                            withCompletion:^{
                                [strongSelf buildIndexForEntities:indexObjects
                                                   withCompletion:^{
                                                       strongSelf.indexing = NO;
                                                   }];
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

- (NSString *)queryStringFromInput:(NSString *)string
{
    NSArray *stringComponents = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableString *returnString = [NSMutableString new];
    for (NSString *substring in stringComponents) {
        if ([substring isEqualToString:[stringComponents lastObject]]) {
            [returnString appendFormat:@"%@*", substring];
        } else {
            [returnString appendFormat:@"%@* ", substring];
        }
    }
    
    return [NSString stringWithString:returnString];
}

- (NSString *)indexStringForObject:(NSManagedObject *)object
{
    NSMutableString *indexString = [NSMutableString new];
    for (NSString *attribute in (NSArray *)self.indexedEntities[object.entity.name]) {
        NSSet *tokenizedAttributes = [self tokenizeString:[object valueForKey:attribute]];
        for (NSString *attributeToken in tokenizedAttributes) {
            [indexString appendString:[NSString stringWithFormat:@"%@ ", attributeToken]];
        }
    }
    
    return [NSString stringWithString:indexString];
}

- (NSString *)indexStringForAttributeString:(NSString *)attribute
{
    NSMutableString *indexString = [NSMutableString new];
    NSSet *tokenizedAttributes = [self tokenizeString:attribute];
    for (NSString *attributeToken in tokenizedAttributes) {
        [indexString appendString:[NSString stringWithFormat:@"%@ ", attributeToken]];
    }
    
    return [NSString stringWithString:indexString];
}

- (void)clearIndexForEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion
{
    @autoreleasepool {
        
        for (NSManagedObject *clearObject in entities) {
            dispatch_group_async(fts4_search_clear_indexing_group(), fts4_search_clear_indexing_queue(), ^{
                for (NSString *attribute in (NSArray *)self.indexedEntities[clearObject.entity.name]) {
                    [[[LSTestManager sharedManager] dbQueue] inDatabase:^(FMDatabase *db) {
                        [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE name = ?", LSFTS4IndexName(clearObject.entity.name, attribute)], clearObject.objectID.URIRepresentation.absoluteString];
                    }];
                }
            });
        }
        
        dispatch_group_notify(fts4_search_clear_indexing_group(), fts4_search_clear_indexing_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }
}

- (void)updateIndexForEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion
{
    @autoreleasepool {
        for (NSManagedObject *updateObject in entities) {
            dispatch_group_async(fts4_search_update_indexing_group(), fts4_search_update_indexing_queue(), ^{
                for (NSString *attribute in (NSArray *)self.indexedEntities[updateObject.entity.name]) {
                    NSString *indexString = [self indexStringForAttributeString:[updateObject valueForKey:attribute]];
                    [[[LSTestManager sharedManager] dbQueue] inDatabase:^(FMDatabase *db) {
                        [db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET contents = ? WHERE name = ?;", LSFTS4IndexName(updateObject.entity.name, attribute)], indexString, updateObject.objectID.URIRepresentation.absoluteString];
                    }];
                }
            });
        }
        dispatch_group_notify(fts4_search_update_indexing_group(), fts4_search_update_indexing_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }
}

- (void)buildIndexForEntities:(NSSet *)entities withCompletion:(LSIndexEntitiesCompletionBlock)completion
{
    @autoreleasepool {
        for (NSManagedObject *updateObject in entities) {
            dispatch_group_async(fts4_search_indexing_group(), fts4_search_indexing_queue(), ^{
                for (NSString *attribute in (NSArray *)self.indexedEntities[updateObject.entity.name]) {
                    NSString *indexString = [self indexStringForAttributeString:[updateObject valueForKey:attribute]];
                    [[[LSTestManager sharedManager] dbQueue] inDatabase:^(FMDatabase *db) {
                        [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (name, contents) VALUES(?, ?);", LSFTS4IndexName(updateObject.entity.name, attribute)], updateObject.objectID.URIRepresentation.absoluteString, indexString];
                    }];
                }
            });
        }
        dispatch_group_notify(fts4_search_indexing_group(), fts4_search_indexing_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }
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

@end
