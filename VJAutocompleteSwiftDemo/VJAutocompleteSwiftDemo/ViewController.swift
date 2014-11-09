//
//  ViewController.swift
//  VJAutocompleteSwiftDemo
//
//  Created by Jakub Vlasák on 14/09/14.
//  Copyright (c) 2014 Jakub Vlasak. All rights reserved.
//

import UIKit


class ViewController: UIViewController, VJAutocompleteDataSource, VJAutocompleteDelegate {
    
    
    // -------------------------------------------------------------------------------
    // MARK: - Public properties
    // -------------------------------------------------------------------------------
    
    // Outlets
    @IBOutlet weak var mainTextField: UITextField!
    
    
    // -------------------------------------------------------------------------------
    // MARK: - Private properties
    // -------------------------------------------------------------------------------
    var sourceDataArray = [AnyObject]();
    var mainAutocomplete: VJAutocomplete!;
    
    
    // -------------------------------------------------------------------------------
    // MARK - Lifecycle
    // -------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceDataArray = Country.listOfCountries();
        
        // Initialize it with initWithTextField is recomended
        mainAutocomplete = VJAutocomplete(textField: mainTextField);
        setupAutocomplete();
        
        mainTextField.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK - VJAutocomplete data source
    // -------------------------------------------------------------------------------
    
    func setCell(cell: UITableViewCell, withItem item: AnyObject) -> UITableViewCell {
        cell.textLabel.text = item as NSString;
        cell.textLabel.font = UIFont.systemFontOfSize(15.0);
        return cell;
    }
    
    func getItemsArrayWithSubstring(substring: String) -> [AnyObject] {
        let beginsWithPredicate = NSPredicate(format: "SELF beginswith[c] %@", substring);
        var searchedCountriesArray  = (sourceDataArray as NSArray).filteredArrayUsingPredicate(beginsWithPredicate!);
        return searchedCountriesArray;
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK - VJAutocomplete delegate
    // -------------------------------------------------------------------------------
    
    func autocompleteWasSelectedRow(rowIndex: Int) {
        mainTextField.resignFirstResponder();
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK - Private methods
    // -------------------------------------------------------------------------------
    
    private func setupAutocomplete() {
        // Set the data source as self
        mainAutocomplete.autocompleteDataSource = self;
        // Set the delegate as self
        mainAutocomplete.autocompleteDelegate = self;
        // Set minimum count of characters to show autocomplete
        mainAutocomplete.minCountOfCharsToShow = 1;
        // Set maximum of visible rows
        mainAutocomplete.maxVisibleRowsCount = 2;
        // Set cell height
        mainAutocomplete.cellHeight = 32;
        // Set border
        mainAutocomplete.setBorder(1.5, cornerRadius: 8.0, color: UIColor.groupTableViewBackgroundColor());
    }

    
}

