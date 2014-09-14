//
//  VJAutocomplete.h
//
//  Created by Jakub Vlasák on 11/09/14.
//  Copyright (c) 2014 Jakub Vlasak ( http://vlasakjakub.com )
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>

/*! Protocol for manipulation of data
 */
@protocol VJAutocompleteDataSource <NSObject>

/*! Set the text of cell with given data. Data can be any object not only string.
 Always return the parameter cell. Only set text. ([cell.textLabel setText:])
 /param cell
 /param item Source data. Data can be any object not only string that is why you have to define the cell text.
 /return cell that has been given and modified
 */
- (UITableViewCell *)setCell:(UITableViewCell *)cell withItem:(id)item;

/*! Define data that should by shown by autocomplete on substring. Can be any object. Not only NSString.
 /param substring
 /return array of objects for substring
 */
- (NSArray *)getItemsArrayWithSubstring:(NSString *) substring;

@end


/*! Protocol for manipulation with VJAutocomplete
 */
@protocol VJAutocompleteDelegate <NSObject>

@optional
/*! This is called when row was selected and autocomplete add text to text field.
 /param rowIndex Selected row number
 /return array of objects for substring
 */
- (void)autocompleteWasSelectedRow:(NSInteger) rowIndex;

@end


/*! VJAutocomplet table for text field is pinned to the text field that must be given. User starts
 writing to the text field and VJAutocomplete show if has any suggestion. If there is no
 suggestion then hide. User can choose suggestion by clicking on it. If user choose any suggestion
 then it diseppeared and add text to text field. If user continues adding text then
 VJAutocomplete start showing another suggestions or diseppead if has no.
*/
@interface VJAutocomplete : UITableView <UITableViewDataSource, UITableViewDelegate>

// -------------------------------------------------------------------------------
#pragma mark - Public properties
// -------------------------------------------------------------------------------

// Set by init
@property (weak, nonatomic) UITextField *textField; //!< Given text field. To this text field is autocomplete pinned to.
@property (weak, nonatomic) UIView *parentView; //!< Parent view of text field (Change only if the current view is not what you want)

// Actions properties
@property (nonatomic) BOOL doNotShow; //!< Do not show autocomplete

// Other properties
@property (nonatomic) NSUInteger maxVisibleRowsCount; //!< Maximum height of autocomplete based on max visible rows
@property (nonatomic) NSUInteger cellHeight; //!< Cell height
@property (nonatomic) NSUInteger minCountOfCharsToShow; //!< Minimum count of characters needed to show autocomplete

@property(nonatomic,assign) id<VJAutocompleteDataSource> autocompleteDataSource; //!< Manipulation with data
@property(nonatomic,assign) id<VJAutocompleteDelegate> autocompleteDelegate; //!< Manipulation with autocomplete

// -------------------------------------------------------------------------------
#pragma mark - Public methods
// -------------------------------------------------------------------------------
//! Setup border of autocomplete
- (void)setBorderWidth:(CGFloat)borderWidth
          cornerRadius:(CGFloat)cornerRadius
                 color:(UIColor *)color;

/*! Initialize autocomplete with text field.
 \param textField UITextField that autocomplete is pinned to
 */
- (id)initWithTextField:(UITextField *)textField;

/*! Get suggestions. Check given text and compare it to data.
 If anything is similar to given text then add it to suggestions.
 Then show self if there are any suggestions or hide if there
 is none. Then reload data in table. Get the suggestins with VJAutocompleteDataSource
 and it is done by on background thread.
 \param substring
 */
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;

/*! Hide self and remove from super view. And set isVisible to NO.
 Only if has been visible else do nothing.
 */
- (void)hideAutocomplete;


/*! Show self. If self is already visible then remove self from super view and show
 again. Count self height according to number of sugestions.
 */
- (void)showAutocomplete;

/*! Call searchAutocompleteEntriesWithSubstring: and give substring in range from text field.
 \param range Range of text
 \param string Text in text field
 */
- (void)shouldChangeCharactersInRange:(NSRange)range
                    replacementString:(NSString *)string;

/*! Is autocomplete visible?
 \return boolean
 */
- (BOOL)isAutocompleteVisible;


@end
