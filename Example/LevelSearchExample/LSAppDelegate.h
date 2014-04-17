//
//  TGAppDelegate.h
//  LevelSearchExample
//
//  Created by John Tumminaro on 4/13/14.
//  Copyright (c) 2014 Tiny Little Gears. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
