//
//  LSTestManager.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "LSTestManager.h"
#import "LSFTS4Manager.h"
#import <MessagePackPacker.h>
#import <MessagePack.h>
#import "Song.h"
#import "Song+Factory.h"

NSString * const kPathForSqliteDB = @"/sqlite.db";

static dispatch_queue_t serial_test_query_queue() {
    static dispatch_queue_t level_search_query_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        level_search_query_queue = dispatch_queue_create("com.tinylittlegears.levelsearch.test.serialQueryQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return level_search_query_queue;
}

@interface LSTestManager ()
@property (nonatomic, assign, readwrite) LSTestMode currentMode;
@end

@implementation LSTestManager

#pragma mark - Initialization

+ (instancetype)sharedManager
{
    static dispatch_once_t onceQueue;
    static LSTestManager *testManager = nil;
    
    dispatch_once(&onceQueue, ^{ testManager = [[self alloc] init]; });
    return testManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
    return self;
}

#pragma mark - Setup

- (void)setupWithTestMode:(LSTestMode)mode
{
    [self resetTesting];
    
    switch (mode) {
        case LSTestModeCoreData:
            [self setupCoreData];
            break;
            
        case LSTestModeFTS4:
            [self setupSqlite];
            break;
            
        case LSTestModeSearchKit:
            [self setupSearchKit];
            break;
            
        case LSTestModeRestKit:
            [self setupRestkit];
            break;
            
        case LSTestModeLevelSearch:
            [self setupLevelSearch];
            break;
            
        default:
            break;
    }
}

- (void)resetTesting
{
    DDLogWarn(@"Starting reset of testing stores");
    
    NSString *sqlitePath = [NSString stringWithFormat:@"%@%@", LSAppDataDirectory(), kPathForSqliteDB];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sqlitePath]) {
        DDLogInfo(@"Deleting sqlite file");
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:sqlitePath error:&error];
        NSAssert(!error, @"Error deleting sqlite file!");
        if (error) {
            DDLogError(@"Error deleting sqlite file %@", error);
        }
    }
    
    if ([[RKObjectManager sharedManager] managedObjectStore]) {
        DDLogInfo(@"Resetting RestKit store");
        NSError *error;
        [[[RKObjectManager sharedManager] managedObjectStore] resetPersistentStores:&error];
        NSAssert(!error, @"Error resetting RestKit store!");
        if (error) {
            DDLogError(@"Error resetting RestKit store %@", error);
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSPersistentStore MR_defaultLocalStoreUrl].path]) {
        DDLogInfo(@"Deleting MagicalRecord store file");
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[NSPersistentStore MR_defaultLocalStoreUrl].path error:&error];
        NSAssert(!error, @"Error deleting MagicalRecord store file!");
        if (error) {
            DDLogError(@"Error deleting MagicalRecord store file %@", error);
        }
    }
    
    DDLogInfo(@"Purging LevelSearch index");
    [[LSIndex sharedIndex] purgeDiskIndex];
    
    DDLogInfo(@"Reset all testing stores");    
}

- (void)runPerformanceTestsWithNumberOfObjects:(NSUInteger)objects numberOfQueries:(NSUInteger)queries
{
    DDLogInfo(@"Starting performance test run.");
    
    switch (self.currentMode) {
        case LSTestModeFTS4:
            [[LSFTS4Manager sharedManager] stopWatchingDefaultContext];
            break;
            
        case LSTestModeSearchKit:
            break;
            
        case LSTestModeRestKit:
            break;
            
        case LSTestModeLevelSearch:
            [[LSIndex sharedIndex] stopWatchingManagedObjectContext:[NSManagedObjectContext MR_rootSavingContext]];
            break;
            
        default:
            break;
    }
    
    DDLogInfo(@"Creating %lu songs", objects);
    [Song createNumberOfSongs:objects];
    NSSet *songs = [NSSet setWithArray:[Song MR_findAll]];
    DDLogInfo(@"Created %lu songs", objects);
    [Book createNumberOfBooks:100];
    NSSet *books = [NSSet setWithArray:[Book MR_findAll]];
    
    switch (self.currentMode) {
        case LSTestModeCoreData:
        {
            for (int x = 0; x < queries; x++) {
                dispatch_async(serial_test_query_queue(), ^{
                    LSStopwatch *queryStopwatch = [LSStopwatch new];
                    [queryStopwatch start];
                    NSString *query = LSGetRandomStringWithCharCount(3);
                    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
                    fetch.predicate = [NSPredicate predicateWithFormat:@"(title LIKE[cd] %@) OR (artist LIKE[cd] %@) OR (album LIKE[cd] %@)", query, query, query];
                    fetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO]];
                    fetch = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
                    fetch.predicate = [NSPredicate predicateWithFormat:@"content LIKE[cd] %@", query];
                    fetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
                    [[NSManagedObjectContext MR_contextForCurrentThread] executeFetchRequest:fetch error:nil];
                    [queryStopwatch stop];
                    DDLogInfo(@"Query time: %f seconds", [queryStopwatch recordedTime]);
                });
            }
        }
            break;
            
        case LSTestModeFTS4:
            break;
            
        case LSTestModeSearchKit:
            break;
            
        case LSTestModeRestKit:
            break;
            
        case LSTestModeLevelSearch:
        {
            LSStopwatch *stopwatch = [LSStopwatch new];
            [stopwatch start];
            [[LSIndex sharedIndex] indexEntities:books withCompletion:^{
                [stopwatch stop];
                DDLogInfo(@"Time to index %f seconds", [stopwatch recordedTime]);
                for (int x = 0; x < queries; x++) {
                    dispatch_async(serial_test_query_queue(), ^{
                        NSString *query = LSGetRandomStringWithCharCount(3);
                        LSStopwatch *queryStopwatch = [LSStopwatch new];
                        [queryStopwatch start];
                        [[LSIndex sharedIndex] queryWithString:query];
                        [queryStopwatch stop];
                        DDLogInfo(@"Query time: %f seconds", [queryStopwatch recordedTime]);
                    });
                }
            }];
        }
            break;
            
        default:
            break;
    }

    
}


#pragma mark - Private

- (void)setupRestkit
{
    self.currentMode = LSTestModeRestKit;
    
    NSError *error;
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        DDLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Store.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (! persistentStore) {
        DDLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
    [managedObjectStore createManagedObjectContexts];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
    manager.managedObjectStore = managedObjectStore;
}

- (void)setupSqlite
{
    self.currentMode = LSTestModeFTS4;
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [Book MR_truncateAll];
    NSString *sqlitePath = [NSString stringWithFormat:@"%@%@", LSAppDataDirectory(), kPathForSqliteDB];
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:sqlitePath];    
    [[LSFTS4Manager sharedManager] addIndexingToEntity:[NSEntityDescription entityForName:@"Song" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]] forAttributes:@[@"album", @"artist", @"title"]];
    [[LSFTS4Manager sharedManager] startWatchingDefaultContext];
}

- (void)setupCoreData
{
    self.currentMode = LSTestModeCoreData;
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [Book MR_truncateAll];
}

- (void)setupLevelSearch
{
    self.currentMode = LSTestModeLevelSearch;
    
    [[LSIndex sharedIndex] purgeDiskIndex];
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [Book MR_truncateAll];
    [Song MR_truncateAll];
    [[LSIndex sharedIndex] addIndexingToEntity:[NSEntityDescription entityForName:@"Song" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]] forAttributes:@[@"album", @"artist", @"title"]];
    [[LSIndex sharedIndex] addIndexingToEntity:[NSEntityDescription entityForName:@"Book" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]] forAttributes:@[@"content"]];
    [[LSIndex sharedIndex] startWatchingManagedObjectContext:[NSManagedObjectContext MR_rootSavingContext]];
    [[LSIndex sharedIndex] setDefaultQueryContext:[NSManagedObjectContext MR_defaultContext]];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"stopwords" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    NSSet *stopWords = [NSSet setWithArray:json];
    [[LSIndex sharedIndex] setStopWords:stopWords];
}

- (void)setupSearchKit
{
    self.currentMode = LSTestModeSearchKit;

}

@end
