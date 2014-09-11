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
 *  Any object that represents a report item to be displayed in a report list must conform to this protocol.
 */
@protocol AMRefreshingListItemProtocol <NSObject>

@optional
/**
 *  Returns the title to display for the report
 *s
 *  @return An `NSString` with a title for the report
 */
- (NSString *)itemTitle;

/**
 *  Returns the status of the report to display
 *
 *  @return An `NSString` with the status for the report
 */
- (NSString *)itemSubtitle;

/**
 *  Returns the report's main photo file URL
 *
 *  @return An `NSString` with the file URL for the report's main image
 */
- (NSURL *)mainPhotoFileURL;

/**
 *  Returns the report's status icon photo file URL
 *
 *  @return An `NSString` with the file URL for the report's main image
 */
- (NSURL *)secondaryPhotoFileURL;

@end
