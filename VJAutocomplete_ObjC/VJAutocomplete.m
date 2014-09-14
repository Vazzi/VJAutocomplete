//
//  VJAutocomplete.m
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

#import "VJAutocomplete.h"

// -------------------------------------------------------------------------------
// Default values of autocomplete
// -------------------------------------------------------------------------------
#define VJAUTOCOMPLETE_DEFAULT_MAX_VISIBLE_ROWS 2
#define VJAUTOCOMPLETE_DEFAULT_CELL_HEIGHT 44
#define VJAUTOCOMPLETE_DEFAULT_MIN_CHARS 3
// -------------------------------------------------------------------------------
// Cell identifier
// -------------------------------------------------------------------------------
#define VJAUTOCOMPLETE_QUEUE_NAME "VJAutocompleteQueue"
// -------------------------------------------------------------------------------
// Cell identifier
// -------------------------------------------------------------------------------
#define VJAUTOCOMPLETE_CELL_IDENTIFIER @"VJAutocompleteCellIdentifier"
// -------------------------------------------------------------------------------

@interface VJAutocomplete()

// Private properties
@property (nonatomic) NSString *lastSubstring; //!< Last given substring
@property (strong, atomic) NSMutableArray *autocompleteItemsArray; //!< Current suggestions
@property (nonatomic) dispatch_queue_t autocompleteSearchQueue; //!< Queue for searching suggestions
@property (nonatomic) BOOL isVisible; //<! Is autocomplete visible

@end


@implementation VJAutocomplete

// -------------------------------------------------------------------------------
#pragma mark - Init methods
// -------------------------------------------------------------------------------

- (id)initWithTextField:(UITextField *)textField
{
    self = [super init];
    if (self) {
        // Text field
        self.textField = textField;
        // Set parent view as text field super view
        self.parentView = textField.superview;
        // Autocomplete is not visible
        self.isVisible = NO;
        // Maximum visible rows
        self.maxVisibleRowsCount = VJAUTOCOMPLETE_DEFAULT_MAX_VISIBLE_ROWS;
        // Minimum characters
        self.minCountOfCharsToShow = VJAUTOCOMPLETE_DEFAULT_MIN_CHARS;
        
        self.cellHeight = VJAUTOCOMPLETE_DEFAULT_CELL_HEIGHT;
        // Setup table view
        [self setupTableView];
        // Init data array
        self.autocompleteItemsArray = [[NSMutableArray alloc] init];
        // Create queue
        self.autocompleteSearchQueue = dispatch_queue_create(VJAUTOCOMPLETE_QUEUE_NAME, DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}


// -------------------------------------------------------------------------------
#pragma mark - Setups
// -------------------------------------------------------------------------------
- (void)setupTableView
{
    // Protocols
    self.dataSource = self;
    self.delegate = self;
    
    // Properties
    self.scrollEnabled = YES;
    
    // Visual properties
    self.backgroundColor = [UIColor whiteColor];
    self.rowHeight = VJAUTOCOMPLETE_DEFAULT_CELL_HEIGHT;
    
    // Border
    self.layer.cornerRadius = 8.0f;
    self.layer.borderWidth = 1.5f;
    self.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
    
    // Empty footer
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


// -------------------------------------------------------------------------------
#pragma mark - Public methods
// -------------------------------------------------------------------------------

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring
{
    // Last count of items in array
    NSUInteger const lastCount = [self.autocompleteItemsArray count];
    // Remove objects from array
    [self.autocompleteItemsArray removeAllObjects];
    
    // If substring has less than 3 characters then hide and return
    if ( [substring length] < self.minCountOfCharsToShow) {
        [self hideAutocomplete];
        return;
    }
    
    // If substring is the same as before and before it has no suggestions then
    // do not search for suggestions
    if ([self.lastSubstring isEqualToString:[substring substringToIndex:substring.length - 1]]) {
        if ( lastCount == 0 ) {
            self.lastSubstring = substring;
            return;
        }
    }
    
    // Save as last substring
    self.lastSubstring = substring;
    
    __weak __typeof__(self) blockSelf = self;
    
    dispatch_async(self.autocompleteSearchQueue, ^(void) {
        // Save new suggestions
        blockSelf.autocompleteItemsArray =  [[NSMutableArray alloc]
                                             initWithArray:[self.autocompleteDataSource getItemsArrayWithSubstring:substring]];
        
        // Call show or hide autocomplete and reload data on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([blockSelf.autocompleteItemsArray count] != 0) {
                [blockSelf showAutocomplete];
            } else {
                [blockSelf hideAutocomplete];
            }

            [blockSelf reloadData];
            
        });
        
    });
    
}

- (void)hideAutocomplete
{
    if (self.isVisible == NO) {
        return;
    }
    [self removeFromSuperview];
    self.isVisible = NO;
}

- (void)showAutocomplete
{
    
    if ( self.doNotShow ) {
        return;
    }
    
    if (self.isVisible == YES) {
        [self removeFromSuperview];
    }
    
    self.isVisible = YES;
    
    NSInteger visibleRowsCount = [self.autocompleteItemsArray count];
    
    // Set number of cells (do not show more than maxSuggestions)
    if ([self.autocompleteItemsArray count] > self.maxVisibleRowsCount) {
        visibleRowsCount = self.maxVisibleRowsCount;
    }
    // Calculate autocomplete height
    CGFloat height = VJAUTOCOMPLETE_DEFAULT_CELL_HEIGHT * visibleRowsCount;
    
    // Set origin of autocomplete by TextField position
    CGPoint textViewOrigin;
    if ([self.parentView isEqual:self.textField.superview]) {
        textViewOrigin = self.textField.frame.origin;
    } else {
        textViewOrigin = [self.textField convertPoint:self.textField.frame.origin
                                               toView:self.parentView];
    }
    
    // Set frame of autocomplete
    CGRect newFrame = CGRectMake(textViewOrigin.x, textViewOrigin.y + CGRectGetHeight(self.textField.bounds), CGRectGetWidth(self.textField.bounds), height);
    self.frame = newFrame;
    // Show in front of everything
    self.layer.zPosition = MAXFLOAT;
    
    [self.parentView addSubview:self];
}

- (void)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Get the current string from textfield
    NSString *substring = [NSString stringWithString:self.textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    // Search for suggestions
    [self searchAutocompleteEntriesWithSubstring:substring];
}

- (BOOL)isAutocompleteVisible
{
    return self.isVisible;
}


// -------------------------------------------------------------------------------
#pragma mark - UITableView data source
// -------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{
    return [self.autocompleteItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VJAUTOCOMPLETE_CELL_IDENTIFIER];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:VJAUTOCOMPLETE_CELL_IDENTIFIER];
    }
    
    cell = [self.autocompleteDataSource setCell:cell withItem:[self.autocompleteItemsArray objectAtIndex:indexPath.row]];
    
    return cell;
}


// -------------------------------------------------------------------------------
#pragma mark - UITableView delegate
// -------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the cell
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    // Set text to
    self.textField.text = selectedCell.textLabel.text;
    // Hide self
    [self hideAutocomplete];
    // Call delegate method
    [self.autocompleteDelegate autocompleteWasSelectedRow:indexPath.row];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}


@end

