//
//  LSSearchManager.m
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import "LSSearchManager.h"

@interface LSSearchManager () <LSIndexDelegate>

@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, copy) NSArray *searchResults;
@property (nonatomic, strong) NSSortDescriptor *sortByName;

@end

@implementation LSSearchManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[LSIndex sharedIndex] setDelegate:self];
        self.sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    }
    return self;
}

#pragma mark - Search Controller Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchCell"];
    }
    
    Person *person = self.searchResults[indexPath.row];
    cell.textLabel.text = person.name;
    
    return cell;
}

#pragma mark - Search Controller Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.searchString = searchString;
    __weak typeof(self) weakSelf = self;
    [[LSIndex sharedIndex] queryInBackgroundWithString:searchString
                                           withResults:^(NSSet *results) {
                                               __strong typeof(weakSelf) strongSelf = weakSelf;
                                               strongSelf.searchResults = [results sortedArrayUsingDescriptors:@[strongSelf.sortByName]];
                                               [strongSelf.searchDisplayController.searchResultsTableView reloadData];
                                           }];
    return NO;
}

#pragma mark - LSIndex Delegate

- (void)searchIndexDidStartIndexing:(LSIndex *)aIndex
{
    NSLog(@"Started indexing");
}

- (void)searchIndexDidFinishIndexing:(LSIndex *)aIndex
{
    NSLog(@"Finished indexing");
}

@end
