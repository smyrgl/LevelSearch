//
//  Book+Factory.m
//  LevelSearchBenchmarking
//
//  Created by John Tumminaro on 4/18/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import "Book+Factory.h"
#import "TestDataManager.h"

@implementation Book (Factory)

+ (void)createBook
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        Book *candide = [Book MR_createEntity];
        candide.name = @"Candide";
        NSString *pathToDoc = [[NSBundle mainBundle] pathForResource:@"candide" ofType:@"txt"];
        NSError *error;
        candide.content = [NSString stringWithContentsOfFile:pathToDoc encoding:NSUTF8StringEncoding error:&error];
    }];
}

+ (void)createNumberOfBooks:(NSUInteger)number
{
    NSArray *booksArray = @[
                            @"divinecomedy",
                            @"aliceinwonderland",
                            @"huckfinn",
                            @"candide",
                            @"prideandprej"
                            ];
    
    for (int x = 0; x < number; x++) {
        NSString *bookName = booksArray[arc4random_uniform((uint32_t)booksArray.count)];
        NSString *pathToDoc = [[NSBundle mainBundle] pathForResource:bookName ofType:@"txt"];
        Book *newBook = [Book MR_createEntity];
        newBook.name = [NSString stringWithFormat:@"Book #%d", x];
        newBook.content = [NSString stringWithContentsOfFile:pathToDoc encoding:NSUTF8StringEncoding error:nil];
    }
}

@end
