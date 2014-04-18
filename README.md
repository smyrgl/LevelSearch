# LevelSearch

[![Build Status](https://travis-ci.org/smyrgl/LevelSearch.svg?branch=master)](https://travis-ci.org/smyrgl/LevelSearch)
[![Version](http://cocoapod-badges.herokuapp.com/v/LevelSearch/badge.png)](http://cocoadocs.org/docsets/LevelSearch)
[![Platform](http://cocoapod-badges.herokuapp.com/p/LevelSearch/badge.png)](http://cocoadocs.org/docsets/LevelSearch)

## Introduction

Although Apple has an existing full text search solution in the form of [Search Kit](https://developer.apple.com/library/mac/documentation/userexperience/conceptual/SearchKitConcepts/searchKit_intro/searchKit_intro.html) there are several major drawbacks with it.

- It is Mac OS X only. 
- It is a C-based API in the [Core Services Framework](https://developer.apple.com/library/mac/documentation/Carbon/Reference/CoreServicesReferenceCollection/_index.html) and does not have an equivalent Objective-C API.
- It is not integrated with Core Data and although it can be bootstrapped into working with Core Data, it isn't quite a drop-in solution.

There are a few other solutions to this problem out there but they aren't perfect:

- You can use [NSPredicate](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSPredicate_Class/Reference/NSPredicate.html) and do queries using CONTAINS or BEGINSWITH.  This really starts to become infesible quickly, especially if you want to perform case and diacritic insensitive searches.
- [RestKit](https://github.com/RestKit/RestKit/) has a search solution that works with Core Data and fashions its search index as an object within the same Core Data store as the models you are indexing.  This is convenient but it is tied pretty tightly into RestKit itself and I found the performance was not fantastic using sqlite on either the indexing side or search.  This is an understandable limitation given that Core Data and sqlite are not all that well optimized for this use case.
- You can make use of the FTS3/FTS4 extensions in sqlite as [described here](http://themainthread.com/blog/2013/04/adding-full-text-search-to-core-data.html).  Although this works it requires bundling a custom build of sqlite3 with your app (which has some configuration challenges alongside Core Data since it uses an older version) and it still requires manually handling the Core Data save notifications and performing the custom indexing.  

This is where LevelSearch comes into play.  It is designed with the goal of being dead simple to integrate while being very low touch (no objc/runtime or associated objects) while providing performance that can meet the needs of full text search for use cases as latency sensitive as auto-complete.  

## Architecture

LevelSearch as the name suggests is built on the [LevelDB](https://code.google.com/p/leveldb/) key/value database developed by Google under the BSD license.  It's a high performance key/value store like Redis but built for embedded client purposes like the Chrome browser which makes it really nice for this usecase.  For more info you can take a look at the Google documentation.

What this means is that LevelSearch utilizes a LevelDB instance for each index which is file backed and handles its own persistence.  LevelSearch supports a single shared convenience index or multiple named indexes--its totally up to your use case as to how you want to most efficiently utilize it.

Beyond the technology though LevelSearch is really easy to use because it manages all of the index changes for you using Core Data save notifications.  Once it starts watching a given `NSManagedObjectContext` the index will happily continue indexing and updating the index whenever changes are detected from Core Data.  This tight coupling makes Level Search really streamlined and the implementation is pretty lean at ~500 LOC (not counting the LevelDB library and Objective-C wrapper).

It's also REALLY DAMN FAST, see the benchmarks below for more on that.

## Installation

The easiest way is through [CocoaPods](http://cocoapods.org), to install just add the following to your Podfile:

		pod "LevelSearch"

After that just import the shared header and you are good to go.

```objective-c
#import <LevelSearch/LevelSearch.h> 
```

## Usage

Using LevelSearch is pretty simple, you just need to configure the index and it takes care of the rest.

#### Configuring the index

If you only need a single index then the shared index works well.  To set it up just do the following after your Core Data stack has been setup:

```objective-c
 [[LSIndex sharedIndex] addIndexingToEntity:[NSEntityDescription entityForName:@"ExampleEntity" inManagedObjectContext:ExampleContext] forAttributes:@[@"attribute1", @"attribute2"]];
 [[LSIndex sharedIndex] startWatchingManagedObjectContext:ExampleContext];
```

It really is that easy.  An important caveat to be aware of though is that because LevelSearch does not use any runtime tricks it does not have the ability to add any kind of primary key to your managed objects.  This is a GOOD thing for the most part but since the only real primary key Core Data provides is the [NSManagedObjectID](https://developer.apple.com/library/mac/documentation/cocoa/reference/CoreDataFramework/Classes/NSManagedObjectID_Class/Reference/NSManagedObjectID.html) it requires objects to be saved to the persistent store before they can be indexed (since objectIDs are temporary and can change until the object is saved).  

What this means to you is that you want to watch an NSManagedObjectContext that is connected directly to the NSPersistentStoreCoordinator and not a child context.  If you are using only a single context like Apple's default Core Data code then you are fine, if you use MagicalRecord (or a similar stack that uses a main-thread context and a parent saving context) then you want to do something like:

```objective-c
 [[LSIndex sharedIndex] startWatchingManagedObjectContext:[NSManagedObjectContext MR_rootSavingContext]];
```

After the index is configured you really don't need to do anything else, the index will register for Core Data save notifications and automatically index objects as they are saved.  If you want more granularity into when indexing is occuring you can use either the `LSIndexDelegate` protocol or the notifications.  Both are fully documented.

## Querying the index

There are two sets of query methods: synchronous and async query methods.  For most everyone the async methods are VASTLY preferred as you really don't want any latency on the main thread while a user is typing a search term.  The sync methods are useful for testing and for implementing your own async searches if you want to own the search queue but please do us all a favor and don't call them from the main thread.  

Otherwise the query interface is identical between the sync and async queries, a simple query looks like this:

```objective-c
	    [[LSIndex sharedIndex] queryInBackgroundWithString:@"example query"
                                           withResults:^(NSSet *results) {
                                               // Put your completion code here...
                                           }];

```

The return from the query is an `NSSet` of objects from Core Data, you don't even need to perform your own `NSFetchRequest`...the query takes care of all of that for you.  You will probably want to sort the results into an `NSArray` using an `NSSortDescriptor` before presenting it but that's pretty straightforward.

## Example Project

To run the example project; clone the repo, and run `pod install` from the root directory first.  There are two sample applications: one that demonstrates how to integrate the framework and another that is used for performance and integration testing.

## Benchmarks

#### Versus Core Data alone

#### Versus RKSearchIndexer (RestKit)

#### Versus sqlite(FTS4)

#### Versus Search Kit

## Requirements


## Author

John Tumminaro, john@tinylittlegears.com

## License

LevelSearch is available under the MIT license. See the LICENSE file for more info.

