//
//  VJViewController.m
//  VJAutocompleteDemo
//
//  Created by Jakub Vlasák on 11/09/14.
//  Copyright (c) 2014 Jakub Vlasak. All rights reserved.
//

// Header
#import "VJViewController.h"
// View
#import "VJAutocomplete.h"
// Model
#import "VJCountry.h"


@interface VJViewController () <VJAutocompleteDataSource, VJAutocompleteDelegate>

// Private properties
@property (strong, nonatomic) NSArray *sourceDataArray;
@property (strong, nonatomic) VJAutocomplete *mainAutocomplete;

@end

@implementation VJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // Data source
    self.sourceDataArray = [VJCountry listOfCountries];
    
    // Initialize autocomplete
    [self initializeAndSetupAutocomplete];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// -------------------------------------------------------------------------------
#pragma mark - Private methods
// -------------------------------------------------------------------------------

//! Initialize and setup autocomplete.
- (void)initializeAndSetupAutocomplete
{
    // Initialize it with initWithTextField is recomended
    self.mainAutocomplete = [[VJAutocomplete alloc] initWithTextField:self.mainTextField];
    // Set the data source as self
    [self.mainAutocomplete setAutocompleteDataSource:self];
    // Set the delegate as self
    [self.mainAutocomplete setAutocompleteDelegate:self];
    // Set minimum count of characters to show autocomplete
    self.mainAutocomplete.minCountOfCharsToShow = 1;
    // Set maximum of visible rows
    self.mainAutocomplete.maxVisibleRowsCount = 2;
}

// -------------------------------------------------------------------------------
#pragma mark - UITextFiled delegate
// -------------------------------------------------------------------------------

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    [self.mainAutocomplete shouldChangeCharactersInRange:range replacementString:string];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.mainAutocomplete hideAutocomplete];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self.mainAutocomplete hideAutocomplete];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.mainAutocomplete hideAutocomplete];
    
    return YES;
}


// -------------------------------------------------------------------------------
#pragma mark - VJAutocomplte data source
// -------------------------------------------------------------------------------

- (UITableViewCell *) setCell:(UITableViewCell *)cell withItem:(id)item
{
    [cell.textLabel setText:(NSString *)item];
    return cell;
}

- (NSArray *) getItemsArrayWithSubstring:(NSString *) substring
{
    // Create predicate
    NSPredicate *beginsWithPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@",
                                        substring];
    
    // Filter data
    NSArray *searchedCountriesArray = [self.sourceDataArray filteredArrayUsingPredicate:beginsWithPredicate];
    
    return searchedCountriesArray;
}


// -------------------------------------------------------------------------------
#pragma mark - VJAutocomplte data source
// -------------------------------------------------------------------------------
- (void)autocompleteWasSelectedRow:(NSInteger)rowIndex
{
    [self.mainTextField resignFirstResponder];
}


@end
