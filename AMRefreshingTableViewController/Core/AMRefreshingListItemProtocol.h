//
//  AMRefreshingListItemProtocol.h
//  AMRefreshingTableViewController
//
//  Created by Anthony Miller on 9/2/14.
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
//

/**
 *  This protocol defines methods that can be implemented by a list item to be displayed in an `AMRefreshingTableViewController` to configure the display of the item in the table view.
 */
@protocol AMRefreshingListItemProtocol <NSObject>

@optional
/**
 *  Returns the title to display for the list item
 *s
 *  @return An `NSString` with a title for the list item
 */
- (NSString *)itemTitle;

/**
 *  Returns the subtitle of the list item to display
 *
 *  @return An `NSString` with a subtitle for the list item
 */
- (NSString *)itemSubtitle;

/**
 *  Returns the list item's main photo file URL
 *
 *  @return An `NSString` with the file URL for the list item's main image
 */
- (NSURL *)mainPhotoFileURL;

/**
 *  Returns the list item's secondary photo file URL
 *
 *  @return An `NSString` with the file URL for the list item's secondary photo
 */
- (NSURL *)secondaryPhotoFileURL;

@end
