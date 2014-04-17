//
//  LSSearchManager.h
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import <Foundation/Foundation.h>

@interface LSSearchManager : NSObject <UISearchDisplayDelegate, UITableViewDataSource>

@property (nonatomic, weak) UISearchDisplayController *searchDisplayController;

@end
