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
#define VJAUTOCOMPLETE_DEFAULT_MAX_CELLS 2
#define VJAUTOCOMPLETE_DEFAULT_CELL_HEIGHT 44
// -------------------------------------------------------------------------------

@interface VJAutocomplete()

// Private properties
@property (nonatomic) NSString *lastSubstring; //!< Last given substring
@property (strong, atomic) NSMutableArray *autocompleteItemsArray; //!< Current suggestions

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
        // Maximum number of suggestion
        self.maxSuggestions = VJAUTOCOMPLETE_DEFAULT_MAX_CELLS;
        // Maximum height of autocomplete
        self.maxHeight = self.maxSuggestions * VJAUTOCOMPLETE_DEFAULT_CELL_HEIGHT;
        
        [self setupTableView];
        
        self.autocompleteItemsArray = [[NSMutableArray alloc] init];
        
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
    NSUInteger lastCount = [self.autocompleteItemsArray count];
    [self.autocompleteItemsArray removeAllObjects];
    
    if ( [substring length] < 3) {
        [self hideAutocomplete];
        return;
    }
    
    if ( [self.lastSubstring isEqualToString:[substring substringToIndex:substring.length - 1]]) {
        if ( lastCount == 0 ) {
            self.lastSubstring = substring;
            return;
        }
    }
    
    self.lastSubstring = substring;
    
    __weak __typeof__(self) blockSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,
                                             (unsigned long)NULL), ^(void) {
        blockSelf.autocompleteItemsArray =  [[NSMutableArray alloc] initWithArray:[self.autocompleteDataSource getItemsArrayWithSubstring:substring]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([blockSelf.autocompleteItemsArray count] != 0)
                [blockSelf showAutocomplete];
            else
                [blockSelf hideAutocomplete];
            
            [blockSelf reloadData];
        });
    });
}

- (void)hideAutocomplete
{
    if(self.isVisible == NO) return;
    [self removeFromSuperview];
    self.isVisible = NO;
}

- (void)showAutocomplete
{
    
    if ( self.doNotShow ) {
        return;
    }
    
    if(self.isVisible == YES)
        [self removeFromSuperview];
    
    self.isVisible = YES;
    
    NSInteger numberOfCells = [self.autocompleteItemsArray count];
    if([self.autocompleteItemsArray count] > self.maxSuggestions)
        numberOfCells = self.maxSuggestions;
    
    CGFloat height = VJAUTOCOMPLETE_DEFAULT_CELL_HEIGHT * numberOfCells;
    
    CGPoint textViewOrigin;
    
    if ( [self.parentView isEqual:self.textField.superview] ) {
        textViewOrigin = self.textField.frame.origin;
    } else {
        textViewOrigin = [self.textField convertPoint:self.textField.frame.origin toView:self.parentView];
    }
    
    CGRect newFrame = CGRectMake(textViewOrigin.x, textViewOrigin.y + CGRectGetHeight(self.textField.bounds), CGRectGetWidth(self.textField.bounds), height);
    
    self.frame = newFrame;
    self.layer.zPosition = MAXFLOAT;
    [self.parentView addSubview:self];
}

- (void)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *substring = [NSString stringWithString:self.textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
}


- (void)maxSuggestions:(NSUInteger)maxSuggestions
{
    self.maxSuggestions = maxSuggestions;
    self.maxHeight = self.maxSuggestions + VJAUTOCOMPLETE_DEFAULT_CELL_HEIGHT;
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
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    cell = [self.autocompleteDataSource setCell:cell withItem:[self.autocompleteItemsArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.textField.text = selectedCell.textLabel.text;
    [self hideAutocomplete];
}


@end

