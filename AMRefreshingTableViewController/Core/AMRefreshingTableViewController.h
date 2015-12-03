//
//  AMRefreshingTableViewController.h
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

#import <UIKit/UIKit.h>

#import <AMPullToRefresh/UITableViewController+AMPullToRefresh.h>
#import <AutoLayoutCells/ALTableViewCellFactory.h>
#import <AutoLayoutCells/ALTableViewCellFactoryDelegate.h>

@protocol AMRefreshingTableViewControllerDelegate;
@protocol AMRefreshingTableViewControllerDataSource;

/**
 * `AMRefreshingTableViewController` is a `UITableViewController` that allows you to display a list of items retrived from an external data source. This controller supports asynchronous data retrieval and has pull to refresh and infinite scrolling capabilities.
 */
@interface AMRefreshingTableViewController : UITableViewController <ALTableViewCellFactoryDelegate, AMPullToRefreshDelegate, UISearchResultsUpdating>

/**
 *  Initializes an instance of `AMRefreshingTableViewController` with a given data source and a number of list items to display per page.
 *
 *  @note The `listItemsPerPage` sets the number of items to request from the data source when loading new list items. For infinite scrolling, this is the number of new items the controller will expect to add to the table view.
 *
 *  @param dataSource       The data source for the controller
 *  @param listItemsPerPage The number of list items to display per page
 *  @param enableSearch     A boolean value indicating if searching should be enabled for the view controller
 *
 *  @return An instance of `AMRefreshingTableViewController`
 */
- (instancetype)initWithDataSource:(id <AMRefreshingTableViewControllerDataSource>)dataSource
                  listItemsPerPage:(NSUInteger)listItemsPerPage
                      enableSearch:(BOOL)enableSearch;

/**
 *  This method load an additional page of list items and inserts them at the bottom of the table view. This method is called automatically when infinite scroll is activated.
 */
- (void)loadNextItems;

/**
 *  This method refreshes the entire list of items. This method is called automatically when pull to refresh is activated.
 */
- (void)refreshList;

/**
 *  The data source for the controller (The data source must implement the `AMRefreshingTableViewControllerDataSource` protocol.)
 */
@property (strong, nonatomic) id <AMRefreshingTableViewControllerDataSource> dataSource;

/**
 *  The delegate for the controller (The delegate must implement the `AMRefreshingTableViewControllerDelegate` protocol.)
 */
@property (weak, nonatomic) id <AMRefreshingTableViewControllerDelegate> delegate;

/**
 *  The number of list items to display per page.
 */
@property (assign, nonatomic) NSUInteger listItemsPerPage;

/**
 *  The array of list items to display. This array is retrieved from the `dataSource`
 *
 *  @note Each list item must implement the `AMRefreshingListItemProtocol` in order to display any data on the table view.
 */
@property (strong, nonatomic) NSMutableArray *listItemsArray;

/**
 *  The last page number that was loaded by the view controller. This is used to keep track of the `offset` to request when loading a new page of items from the data source.
 */
@property (assign, nonatomic) NSUInteger lastPageLoaded;

/**
 *  The `ALTableViewCellFactory` used to create and configure the table view cells for the controller.
 */
@property (strong, nonatomic) ALTableViewCellFactory *cellFactory;

/**
 *  The `UISearchController` to be displayed in the table header view.
 *
 *  @note If search is not enabled, this will be `nil`.
 */
@property (strong, nonatomic) UISearchController *searchController;

@end
