//
//  AMRefreshingTableViewControllerDataSource.h
//  AMRefreshingTableViewController
//
//  Created by Anthony Miller on 9/4/14.
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

#import <Foundation/Foundation.h>

#import "AMRefreshingTableViewController.h"

/******************************************************************
 * Operation Success & Failure Block Types
 ******************************************************************/

/**
 *  This is "success" block that should be returned by the operation manager.
 *
 *  @param operation           The operation
 *  @param reportList          An `NSArray` of objects that conform to this protocol to represent the reports.
 */
typedef void (^AMRefreshingListOperationSuccessBlock)(NSArray * itemList);

/**
 *  This is "failure" block that should be returned by the operation manager.
 *
 *  @param operation  The operation
 *  @param error The error that occurred
 */
typedef void (^AMRefreshingListOperationFailureBlock)(NSError *error);

/******************************************************************
 * Data Source Protocol
 ******************************************************************/

/**
 *  The `AMRefreshingTableViewControllerDataSource` should retrieve the list items to be displayed and return them in an array.
 */
@protocol AMRefreshingTableViewControllerDataSource <NSObject>

/**
 *  This method will be called on the data source when the `AMRefreshingTableViewController` refreshes or needs more list items.
 *
 *
 *
 *  @param tableViewController The `AMRefreshingTableViewController` requesting the list items
 *  @param offset              The offset in the items retrieved
 *  @param quantity            The number of list items to return
 *  @param searchTerm          The optional search term to filter the results by
 *  @param success             The success block to be called, returning an `NSArray` of list items that conform to the `AMRefreshingListItemProtocol`.
 *  @param failure             The failure block to be called, returning an `NSError`
 */
- (void)AMRefreshingTableViewController:(AMRefreshingTableViewController *)tableViewController
                    listItemsWithOffset:(NSUInteger)offset
                               quantity:(NSUInteger)quantity
                             searchTerm:(NSString *)searchTerm
                                success:(AMRefreshingListOperationSuccessBlock)success
                                failure:(AMRefreshingListOperationFailureBlock)failure;

@end