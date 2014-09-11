//
//  AMRefreshingTableViewControllerTests.m
//  AMRefreshingTableViewControllerTests
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

// Test Class
#import "AMRefreshingTableViewController.h"

// Collaborators
#import <AutoLayoutCells/ALImageCell.h>
#import <AutoLayoutCells/ALCellConstants.h>
#import <AutoLayoutCells/ALImageCellConstants.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <UIScrollView-InfiniteScroll/UIScrollView+InfiniteScroll.h>
#import <XMLDictionary/XMLDictionary.h>

#import "AMRefreshingListItemProtocol.h"
#import "AMRefreshingTableViewControllerDataSource.h"
#import "AMRefreshingTableViewControllerDelegate.h"

// Test Support
#import <XCTest/XCTest.h>

#define EXP_SHORTHAND YES
#import <Expecta/Expecta.h>

#import <OCMock/OCMock.h>

@interface AMRefreshingTableViewControllerTests : XCTestCase
@end

@implementation AMRefreshingTableViewControllerTests
{
  AMRefreshingTableViewController *sut;
  UINavigationController *navController;
  id mockSUT;
  id mockTableView;
  id dataSource;
  id mockProgressHUD;
  NSMutableArray *listItemsArray;
}

#pragma mark - Test Lifecycle

- (void)setUp
{
  [super setUp];
  
  sut = [[AMRefreshingTableViewController alloc] initWithDataSource:nil listItemsPerPage:15];
  navController = [[UINavigationController alloc] initWithRootViewController:sut];
  mockSUT = OCMPartialMock(sut);
  mockTableView = OCMPartialMock(sut.tableView);
  OCMStub([mockTableView reloadData]);
  
  [self givenDataSourceWithQuantity:15];
  [sut viewDidLoad];
}

#pragma mark - Utilities

- (void)givenDataSourceWithQuantity:(NSInteger)quantity
{
  dataSource = OCMProtocolMock(@protocol(AMRefreshingTableViewControllerDataSource));
  
  OCMStub([dataSource AMRefreshingTableViewController:sut
                                  listItemsWithOffset:0
                                             quantity:sut.listItemsPerPage
                                              success:[OCMArg any]
                                              failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    
    AMRefreshingListOperationSuccessBlock success;
    
    [invocation getArgument:&success atIndex:5];
    [self givenListItemsArrayWithOffset:0 quantity:quantity];
    
    success(listItemsArray);
    
  });
  
  OCMStub([dataSource AMRefreshingTableViewController:sut
                                 listItemsWithOffset:15
                                             quantity:sut.listItemsPerPage
                                              success:[OCMArg any]
                                              failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    
    AMRefreshingListOperationSuccessBlock success;
    
    [invocation getArgument:&success atIndex:5];
    [self givenListItemsArrayWithOffset:15 quantity:quantity];
    
    success(listItemsArray);
    
  });

  
  sut.dataSource = dataSource;
}

- (void)givenDataSourceWithFailure
{
  dataSource = OCMProtocolMock(@protocol(AMRefreshingTableViewControllerDataSource));
  
  OCMStub([dataSource AMRefreshingTableViewController:sut
                                  listItemsWithOffset:0
                                             quantity:sut.listItemsPerPage
                                              success:[OCMArg any]
                                              failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    
    AMRefreshingListOperationFailureBlock failure;
    
    [invocation getArgument:&failure atIndex:6];
    
    NSError *error = [NSError errorWithDomain:@"test" code:1 userInfo:nil];
    failure(error);
    
  });
  
  sut.dataSource = dataSource;
}

- (void)givenListItemsArrayWithOffset:(NSInteger)offset quantity:(NSInteger)quantity
{
  listItemsArray = [NSMutableArray array];
  
  for (int i = 1; i <= quantity; i++) {
    [listItemsArray addObject:[self listItemWithNumber:i + offset]];
    
  }
}

- (id <AMRefreshingListItemProtocol>)listItemWithNumber:(NSInteger)number
{
  id <AMRefreshingListItemProtocol> listItem = OCMProtocolMock(@protocol(AMRefreshingListItemProtocol));
  NSString *title = [NSString stringWithFormat:@"Item %ld Title", (long)number];
  OCMStub([listItem itemTitle]).andReturn(title);
  
  NSString *subtitle = [NSString stringWithFormat:@"Item %ld Subtitle", (long)number];
  OCMStub([listItem itemSubtitle]).andReturn(subtitle);
  
  NSString *mainURLString = [NSString stringWithFormat:@"mainURL%ld", (long)number];
  NSURL *mainURL = [NSURL URLWithString:mainURLString];
  OCMStub([listItem mainPhotoFileURL]).andReturn(mainURL);
  
  NSString *secondaryURLString = [NSString stringWithFormat:@"secondaryURL%ld", (long)number];
  NSURL *secondaryURL = [NSURL URLWithString:secondaryURLString];
  OCMStub([listItem secondaryPhotoFileURL]).andReturn(secondaryURL);
  
  return listItem;
}

#pragma mark - Object Lifecycle - Tests

- (void)test___initsWithDataSource
{
  // when
  sut = [[AMRefreshingTableViewController alloc] initWithDataSource:dataSource listItemsPerPage:10];
  
  // then
  expect(sut.dataSource).to.equal(dataSource);
}

- (void)test___initsWith_listItemsPerPage
{
  expect(sut.listItemsPerPage).to.equal(15);
}

#pragma mark - View Lifecycle - Tests

- (void)test___viewDidLoad___setsUpPullToRefresh
{
  OCMVerify([mockSUT setUpPullToRefreshView]);
}

- (void)test___viewDidLoad___setsUpInfiniteScroll
{
  OCMVerify([mockTableView addInfiniteScrollWithHandler:[OCMArg any]]);
}

- (void)test___viewDidLoad___setsUpCellFactory
{
  // then
  expect(sut.cellFactory).to.beInstanceOf([ALTableViewCellFactory class]);
  expect(sut.cellFactory.delegate).to.equal(sut);
}

- (void)test___viewDidLoad___showsProgressHUD
{
  // given
  mockProgressHUD = OCMClassMock([MBProgressHUD class]);
  OCMExpect([mockProgressHUD showHUDAddedTo:sut.navigationController.view animated:YES]);
  
  // when
  [sut viewDidLoad];
  
  // then
  OCMVerifyAll(mockProgressHUD);
}

- (void)test___viewDidLoad___loadsReportsWithOffsetZero
{
  // then
  OCMVerify([dataSource AMRefreshingTableViewController:sut
                                    listItemsWithOffset:0
                                               quantity:sut.listItemsPerPage
                                                success:[OCMArg any]
                                                failure:[OCMArg any]]);
}

- (void)test___viewDidLoad___givenSuccess_setsUpReportStubsArray
{
  // then
  expect(sut.listItemsArray).to.equal(listItemsArray);
  expect(sut.listItemsArray.count).to.equal(15);
  expect(sut.lastPageLoaded = 1);
}


- (void)test___viewDidLoad___givenSuccess_hidesProgressHUD
{
  mockProgressHUD = OCMClassMock([MBProgressHUD class]);
  OCMExpect([mockProgressHUD hideAllHUDsForView:sut.navigationController.view animated:YES]);
  
  // when
  [sut viewDidLoad];
  
  // then
  OCMVerifyAll(mockProgressHUD);
}

- (void)test___viewDidLoad___givenFailure_hidesProgressHUD
{
  // given
  mockProgressHUD = OCMClassMock([MBProgressHUD class]);
  OCMExpect([mockProgressHUD hideAllHUDsForView:sut.navigationController.view animated:YES]);
  
  [self givenDataSourceWithFailure];
  
  // when
  [sut viewDidLoad];
  
  // then
  OCMVerifyAll(mockProgressHUD);
}

#pragma mark - Load Next Reports - Tests

- (void)test___loadNextReports___changesLastPageLoaded
{
  // when
  [sut loadNextItems];
  
  // then
  expect(sut.lastPageLoaded).to.equal(2);
}

- (void)test___loadNextReports___addsNewReportStubsToArray
{
  // when
  [sut loadNextItems];
  
  // then
  expect(sut.listItemsArray.count).to.equal(30);
  id <AMRefreshingListItemProtocol> listItem = sut.listItemsArray[9];
  expect([listItem itemTitle]).to.equal(@"Item 10 Title");
}

#pragma mark - UITableViewDataSource - Tests

- (void)test___tableView_numberOfRowsInSection_returnsReportStubsCount
{
  // given
  [self givenDataSourceWithQuantity:10];
  [sut refreshList];
  
  expect([sut tableView:sut.tableView numberOfRowsInSection:1]).to.equal(10);
}

#pragma mark - UITableViewDelegate - Tests

- (void)test___tableView_didSelectRowAtIndexPath___callsDelegateWithCorrectListItem
{
  // given
  id mockDelegate = OCMProtocolMock(@protocol(AMRefreshingTableViewControllerDelegate));
  sut.delegate = mockDelegate;
  
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
  id <AMRefreshingListItemProtocol> expectedListItem = sut.listItemsArray[5];
  
  // when
  [sut tableView:sut.tableView didSelectRowAtIndexPath:indexPath];
  
  // then
  OCMVerify([mockDelegate controller:sut didSelectListItem:expectedListItem]);
}

#pragma mark - ALCellFactoryDelegate - Tests

- (void)test___configureCell_atIndexPath___setsAllValues
{
  // given
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
  NSString *expectedTitle = @"Item 6 Title";
  NSString *expectedSubtitle = @"Item 6 Subtitle";
  NSURL *expectedMainURL = [NSURL URLWithString:@"mainURL6"];
  NSURL *expectedSecondaryURL = [NSURL URLWithString:@"secondaryURL6"];
  
  NSDictionary *expectedDict = @{ALCellTitleKey: expectedTitle,
                                 ALCellSubtitleKey: expectedSubtitle,
                                 ALImageCellMainImageURLKey:  expectedMainURL,
                                 ALImageCellSecondaryImageURLKey: expectedSecondaryURL};
  
  // when
  id mockCell = OCMClassMock([ALImageCell class]);
  [sut configureCell:mockCell atIndexPath:indexPath];
  
  // then
  OCMVerify([mockCell setValuesDictionary:expectedDict]);
}

#pragma mark - AMPullToRefreshDelegate - Tests

- (void)test___refreshViewDidBeginRefreshing_refreshesListItems
{
  // when
  [sut refreshViewDidBeginRefreshing:sut.pullToRefreshView];
  
  // then
  OCMVerify([mockSUT refreshList]);
}

@end