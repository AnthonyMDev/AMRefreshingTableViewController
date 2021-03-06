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
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "AMRefreshingTableViewController.h"

#import <UIKit/UISearchController.h>

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

@interface AMRefreshingTableViewController ()

@property (assign, nonatomic) BOOL hasInfiniteScroll;

@property (assign, nonatomic) BOOL searchEnabled;

@end

@implementation AMRefreshingTableViewController

#pragma mark - Object Lifecycle

- (instancetype)initWithDataSource:(id<AMRefreshingTableViewControllerDataSource>)dataSource
                  listItemsPerPage:(NSUInteger)listItemsPerPage
                      enableSearch:(BOOL)enableSearch
{
  self = [super init];
  
  if (self) {
    self.dataSource = dataSource;
    self.listItemsPerPage = listItemsPerPage;
    self.searchEnabled = enableSearch;
  }
  
  return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self setUpPullToRefreshView];
  [self setUpCellFactory];
  [self setUpSearchController];
}

- (void)setUpCellFactory
{
  self.cellFactory = [[ALTableViewCellFactory alloc]initWithTableView:self.tableView
                                          identifiersToNibsDictionary:[self identifiersToNibsDictionary]];
  self.cellFactory.delegate = self;
}

- (void)setUpSearchController
{
  if (self.searchEnabled) {
    self.definesPresentationContext = YES;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.showsCancelButton = YES;
    
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  if (self.dataSource) {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [self refreshList];
    
  }
}

- (NSDictionary *)identifiersToNibsDictionary
{
  return @{AMRefreshingListItemCellIdentifier: [ALTableViewCellNibFactory menuCellNib]};
}

#pragma mark - Refreshing List

- (void)refreshList
{
  __weak typeof(self) weakSelf = self;
  
  [self.dataSource AMRefreshingTableViewController:self
                               listItemsWithOffset:0
                                          quantity:self.listItemsPerPage
                                        searchTerm:self.searchController.searchBar.text
                                           success:^(NSArray *reportList) {
                                             
                                             __strong typeof(weakSelf) strongSelf = weakSelf;
                                             
                                             strongSelf.listItemsArray = [NSMutableArray arrayWithArray:reportList];
                                             
                                             strongSelf.lastPageLoaded = 1;
                                             [strongSelf.tableView reloadData];
                                             
                                             [strongSelf finishRefreshingList];
                                             
                                           }
                                           failure:^(NSError *error) {
                                             
                                             __strong typeof(weakSelf) strongSelf = weakSelf;
                                             
                                             [strongSelf finishRefreshingList];
                                             [strongSelf displayRefreshFailureAlert];
                                             
                                           }];
}

- (void)finishRefreshingList
{
  [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
  [self.pullToRefreshView endRefreshing];
  [self toggleInfiniteScroll];
}

- (void)displayRefreshFailureAlert
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"There was an error while trying to refresh. Please try again."
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Ok", nil];
  [alertView show];
}

#pragma mark - Infinite Scroll

- (void)toggleInfiniteScroll
{
  if ([self shouldHaveInfiniteScroll] && !self.hasInfiniteScroll) {
    [self addInfiniteScroll];
    
  } else if (![self shouldHaveInfiniteScroll] && self.hasInfiniteScroll) {
    [self removeInfiniteScroll];
  }
}

- (BOOL)shouldHaveInfiniteScroll
{
  return self.listItemsArray.count >= self.listItemsPerPage;
}

- (void)addInfiniteScroll
{
  self.hasInfiniteScroll = YES;
  __weak typeof(self) weakSelf = self;
  [self.tableView addInfiniteScrollWithHandler:^(UIScrollView* scrollView) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    
    [strongSelf loadNextItems];
  }];
}

- (void)removeInfiniteScroll
{
  self.hasInfiniteScroll = NO;
  [self.tableView removeInfiniteScroll];
}

#pragma mark - Load Next Items

- (void)loadNextItems
{
  NSUInteger offset = self.lastPageLoaded * self.listItemsPerPage;
  if (offset > self.listItemsArray.count) {
    [self.tableView finishInfiniteScroll];
    return;
  }
  
  __weak typeof(self) weakSelf = self;
  [self.dataSource AMRefreshingTableViewController:self
                               listItemsWithOffset:offset
                                          quantity:self.listItemsPerPage
                                        searchTerm:self.searchController.searchBar.text
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.delegate controller:self didSelectListItem:self.listItemsArray[indexPath.row]];
}

#pragma mark - ALCellFactoryDelegate

- (NSString *)tableView:(UITableView *)tableView identifierForCellAtIndexPath:(NSIndexPath *)indexPath
{
  return AMRefreshingListItemCellIdentifier;
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath
{
  id <AMRefreshingListItemProtocol> listItem = self.listItemsArray[indexPath.row];
  NSDictionary *valuesDict = [self valuesDictionaryForListItem:listItem];
  [(ALImageCell *)cell setValuesFromDictionary:valuesDict];
}

- (NSDictionary *)valuesDictionaryForListItem:(id <AMRefreshingListItemProtocol>)listItem
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  [self setTitleForDictionary:dict withListItem:listItem];
  [self setSubtitleForDictionary:dict withListItem:listItem];
  [self setMainPhotoForDictionary:dict withListItem:listItem];
  [self setSecondaryPhotoForDictionary:dict withListItem:listItem];
  
  return dict;
}

- (void)setTitleForDictionary:(NSMutableDictionary *)dictionary withListItem:(id <AMRefreshingListItemProtocol>)listItem
{
  if ([listItem respondsToSelector:@selector(itemTitle)]) {
    if ([listItem itemTitle].length) {
      dictionary[ALCellTitleKey] = [listItem itemTitle];
      
    }
  }
}

- (void)setSubtitleForDictionary:(NSMutableDictionary *)dictionary withListItem:(id <AMRefreshingListItemProtocol>)listItem
{
  if ([listItem respondsToSelector:@selector(itemSubtitle)]) {
    if ([listItem itemSubtitle].length) {
      dictionary[ALCellSubtitleKey] = [listItem itemSubtitle];
      
    }
  }
}

- (void)setMainPhotoForDictionary:(NSMutableDictionary *)dictionary withListItem:(id <AMRefreshingListItemProtocol>)listItem
{
  if ([listItem respondsToSelector:@selector(mainPhotoFileURL)]) {
    if ([listItem mainPhotoFileURL]) {
      dictionary[ALImageCellMainImageURLKey] = [listItem mainPhotoFileURL];
      
    }
  }
}

- (void)setSecondaryPhotoForDictionary:(NSMutableDictionary *)dictionary withListItem:(id <AMRefreshingListItemProtocol>)listItem
{
  if ([listItem respondsToSelector:@selector(secondaryPhotoFileURL)]) {
    if ([listItem secondaryPhotoFileURL]) {
      dictionary[ALImageCellSecondaryImageURLKey] = [listItem secondaryPhotoFileURL];
      
    }
  }
}

#pragma mark - AMPullToRefreshDelegate

- (void)refreshViewDidBeginRefreshing:(AMPullToRefreshView *)pullToRefreshView
{
  [self refreshList];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
  [self refreshList];
}

@end
