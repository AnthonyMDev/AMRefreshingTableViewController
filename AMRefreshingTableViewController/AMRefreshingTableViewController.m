//
//  AMRefreshingTableViewController.m
//  AMRefreshingTableViewController
//
//  Created by Anthony Miller on 8/14/14.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "AMRefreshingTableViewController.h"

#import <AutoLayoutCells/ALTableViewCellNibFactory.h>
#import <AutoLayoutCells/ALCellConstants.h>
#import <AutoLayoutCells/ALImageCellConstants.h>
#import <AutoLayoutCells/ALImageCell.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <UIScrollView-InfiniteScroll/UIScrollView+InfiniteScroll.h>

#import "AMRefreshingListItemProtocol.h"
#import "AMRefreshingTableViewControllerDelegate.h"
#import "AMRefreshingTableViewControllerDataSource.h"

static NSString * AMRefreshingListItemCellIdentifier = @"AMRefreshingListItemCellIdentifier";

@implementation AMRefreshingTableViewController

#pragma mark - Object Lifecycle

- (instancetype)initWithDataSource:(id<AMRefreshingTableViewControllerDataSource>)dataSource listItemsPerPage:(NSUInteger)listItemsPerPage
{
  self = [super init];
  
  if (self) {
    self.dataSource = dataSource;
    self.listItemsPerPage = listItemsPerPage;
  }
  
  return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self setUpPullToRefreshView];
  [self setUpInfiniteScroll];
  [self setUpCellFactory];
  
  if (self.dataSource) {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [self refreshList];

  }
}

- (void)setUpInfiniteScroll
{
  __weak typeof(self) weakSelf = self;
  [self.tableView addInfiniteScrollWithHandler:^(UIScrollView* scrollView) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    
    [strongSelf loadNextItems];
  }];
}

- (void)setUpCellFactory
{
  self.cellFactory = [[ALTableViewCellFactory alloc]initWithTableView:self.tableView
                                          identifiersToNibsDictionary:[self identifiersToNibsDictionary]];
  self.cellFactory.delegate = self;
}

- (NSDictionary *)identifiersToNibsDictionary
{
  return @{AMRefreshingListItemCellIdentifier: [ALTableViewCellNibFactory menuCellNib]};
}

- (void)refreshList
{
  __weak typeof(self) weakSelf = self;
  
  [self.dataSource AMRefreshingTableViewController:self
                               listItemsWithOffset:0
                                          quantity:self.listItemsPerPage
                                 success:^(NSArray *reportList) {
                        
                                   __strong typeof(weakSelf) strongSelf = weakSelf;
                        
                                   strongSelf.listItemsArray = [NSMutableArray arrayWithArray:reportList];
                        
                                   self.lastPageLoaded = 1;
                                   [strongSelf.tableView reloadData];
                                   [MBProgressHUD hideAllHUDsForView:strongSelf.navigationController.view animated:YES];
                                   [self.pullToRefreshView endRefreshing];
                        
                                 }

                                 failure:^(NSError *error) {
                        
                                   __strong typeof(weakSelf) strongSelf = weakSelf;

                                   [MBProgressHUD hideAllHUDsForView:strongSelf.navigationController.view animated:YES];
                        

                                 }];
}

- (void)loadNextItems
{
  NSUInteger offset = self.lastPageLoaded * self.listItemsPerPage;
  
  __weak typeof(self) weakSelf = self;
  [self.dataSource AMRefreshingTableViewController:self
                               listItemsWithOffset:offset
                                          quantity:self.listItemsPerPage
                                 success:^(NSArray *itemList) {
                                   
                                   __strong typeof(weakSelf) strongSelf = weakSelf;
    
                                   [self.listItemsArray addObjectsFromArray:itemList];
    
                                   NSArray *newIndexPaths = [strongSelf newIndexPathsArrayWithItemList:itemList
                                                                                                     offset:offset];
    
                                   [self.tableView insertRowsAtIndexPaths:newIndexPaths
                                                            withRowAnimation:UITableViewRowAnimationAutomatic];
                                   
                                   strongSelf.lastPageLoaded ++;
                                   [strongSelf.tableView finishInfiniteScroll];
                                   
                                 }
                                 failure:^(NSError *error) {
                                   
                                   __strong typeof(weakSelf) strongSelf = weakSelf;
    
                                   [strongSelf.tableView finishInfiniteScroll];
                                   
                                 }];
}

- (NSArray *)newIndexPathsArrayWithItemList:(NSArray *)itemList offset:(NSUInteger)offset
{
  NSMutableArray *newIndexPaths = [NSMutableArray array];
  for (NSInteger i = 0; i < itemList.count; i++) {
    NSInteger indexPathRow = offset + i;
    [newIndexPaths addObject:[NSIndexPath indexPathForRow:indexPathRow inSection:0]];
  }
  return [NSArray arrayWithArray:newIndexPaths];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.listItemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = nil;
  
  cell = [self.cellFactory cellWithIdentifier:AMRefreshingListItemCellIdentifier forIndexPath:indexPath];
  
  return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.cellFactory cellHeightForIdentifier:AMRefreshingListItemCellIdentifier atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.delegate controller:self didSelectListItem:self.listItemsArray[indexPath.row]];
}

#pragma mark - ALCellFactoryDelegate

- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath
{
  id <AMRefreshingListItemProtocol> listItem = self.listItemsArray[indexPath.row];
  [(ALImageCell *)cell setValuesDictionary:[self valuesDictionaryForListItem:listItem]];
}

- (NSDictionary *)valuesDictionaryForListItem:(id <AMRefreshingListItemProtocol>)listItem
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  if ([listItem itemTitle].length) {
    dict[ALCellTitleKey] = [listItem itemTitle];
  }
  
  if ([listItem itemSubtitle].length) {
    dict[ALCellSubtitleKey] = [listItem itemSubtitle];
  }
  
  if ([listItem mainPhotoFileURL]) {
    dict[ALImageCellMainImageURLKey] = [listItem mainPhotoFileURL];
  }
  
  if ([listItem secondaryPhotoFileURL]) {
    dict[ALImageCellSecondaryImageURLKey] = [listItem secondaryPhotoFileURL];
  }
  
  return dict;
}

#pragma mark - AOPullToRefreshDelegate

- (void)refreshViewDidBeginRefreshing:(AOPullToRefreshView *)pullToRefreshView
{
  [self refreshList];
}

@end
