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
#import "AOReportListTableViewController.h"

// Collaborators
#import <MBProgressHUD/MBProgressHUD.h>
#import <UIScrollView-InfiniteScroll/UIScrollView+InfiniteScroll.h>
#import <XMLDictionary/XMLDictionary.h>

#import "AOReportListTableViewControllerDataSource.h"

// Test Support
#import <XCTest/XCTest.h>

#define EXP_SHORTHAND YES
#import <Expecta/Expecta.h>

#import <OCMock/OCMock.h>

@interface AOReportListTableViewControllerTests : XCTestCase
@end

@implementation AOReportListTableViewControllerTests
{
  AOReportListTableViewController *sut;
  UINavigationController *navController;
  id mockSUT;
  id mockTableView;
  id dataSource;
  id mockProgressHUD;
  NSMutableArray *reportsArray;
}

#pragma mark - Test Lifecycle

- (void)setUp
{
  [super setUp];
  
  sut = [[AOReportListTableViewController alloc] initWithDataSource:nil reportsPerPage:15];
  navController = [[UINavigationController alloc] initWithRootViewController:sut];
  mockSUT = OCMPartialMock(sut);
  mockTableView = OCMPartialMock(sut.tableView);
  OCMStub([mockTableView reloadData]);
  
  [self givenDataSource];
  [sut viewDidLoad];
}

#pragma mark - Utilities

- (void)givenDataSource
{
  dataSource = OCMProtocolMock(@protocol(AOReportListTableViewControllerDataSource));
  
  OCMStub([dataSource reportListTableViewController:sut reportListWithOffset:0 quantity:sut.reportsPerPage success:[OCMArg any] failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    
    AOReportListOperationSuccessBlock success;
    
    [invocation getArgument:&success atIndex:5];
    [self givenReportsArray];
    
    success(nil, reportsArray);
    
  });
  
  OCMStub([dataSource reportListTableViewController:sut reportListWithOffset:15 quantity:sut.reportsPerPage success:[OCMArg any] failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    
    AOReportListOperationSuccessBlock success;
    
    [invocation getArgument:&success atIndex:5];
    [self givenReportsArray];
    
    success(nil, reportsArray);
    
  });

  
  sut.dataSource = dataSource;
}

- (void)givenDataSourceWithFailure
{
  dataSource = OCMProtocolMock(@protocol(AOReportListTableViewControllerDataSource));
  
  OCMStub([dataSource reportListTableViewController:sut reportListWithOffset:0 quantity:sut.reportsPerPage success:[OCMArg any] failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    
    AOReportListOperationFailureBlock failure;
    
    [invocation getArgument:&failure atIndex:6];
    
    NSError *error = [NSError errorWithDomain:@"test" code:1 userInfo:nil];
    failure(nil, error);
    
  });
  
  sut.dataSource = dataSource;
}

- (void)givenReportsArray
{
  NSData *data = [self dataFromFileName:@"MyReports_Multiple" type:@"xml"];
  [self reportsArrayFromData:data];
}

- (NSData *)dataFromFileName:(NSString *)fileName type:(NSString *)type
{
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSString *path = [bundle pathForResource:fileName ofType:type];
  return [NSData dataWithContentsOfFile:path];
}

- (void)reportsArrayFromData:(NSData *)data
{
  XMLDictionaryParser *parser = [[XMLDictionaryParser alloc] init];
  NSDictionary *dict = [parser dictionaryWithData:data];
  
  reportsArray = [NSMutableArray array];
  
  for (NSDictionary *report in dict[@"report"]) {
    
    [reportsArray addObject:report];
    
  }
  expect(reportsArray.count).to.beGreaterThan(0);
}

#pragma mark - Object Lifecycle - Tests

- (void)test___initsWithDataSource
{
  // when
  sut = [[AOReportListTableViewController alloc] initWithDataSource:dataSource reportsPerPage:10];
  
  // then
  expect(sut.dataSource).to.equal(dataSource);
}

- (void)test___initsWith_reportsPerPage
{
  expect(sut.reportsPerPage).to.equal(15);
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
  OCMVerify([dataSource reportListTableViewController:sut reportListWithOffset:0 quantity:sut.reportsPerPage success:[OCMArg any] failure:[OCMArg any]]);
}

- (void)test___viewDidLoad___givenSuccess_setsUpReportStubsArray
{
  // then
  expect(sut.reportStubsArray).to.equal(reportsArray);
  expect(sut.reportStubsArray.count).to.equal(8);
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
  [sut loadNextReports];
  
  // then
  expect(sut.lastPageLoaded).to.equal(2);
}

- (void)test___loadNextReports___addsNewReportStubsToArray
{
  // when
  [sut loadNextReports];
  
  // then
  expect(sut.reportStubsArray.count).to.equal(16);
}

#pragma mark - UITableViewDataSource - Tests

- (void)test___tableView_numberOfRowsInSection_returnsReportStubsCount
{
  // given
  [self givenDataSource];
  
  expect([sut tableView:sut.tableView numberOfRowsInSection:1]).to.equal(8);
}

@end