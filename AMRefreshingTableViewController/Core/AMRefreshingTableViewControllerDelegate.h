//
//  AMRefreshingTableViewControllerDelegate.h
//  AMRefreshingTableViewController
//
//  Created by Anthony Miller on 9/3/14.
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

@protocol AMRefreshingListItemProtocol;

/**
 *  The delegate of an `AMRefreshingTableViewController` should handle to selection of a list item.
 */
@protocol AMRefreshingTableViewControllerDelegate <NSObject>

/**
 *  This delegate method will be called when `tableView:didSelectRowAtIndexPath:` is called on the `AMRefreshingTableViewController`, returning the list item for the selected row.
 *
 *  @param controller The `AMRefreshingTableViewController`
 *  @param listItem   The list item that was selected
 */
- (void)controller:(AMRefreshingTableViewController *)controller didSelectListItem:(id <AMRefreshingListItemProtocol>)listItem;

@end
