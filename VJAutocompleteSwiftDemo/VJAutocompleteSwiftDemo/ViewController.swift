//
//  ViewController.swift
//  VJAutocompleteSwiftDemo
//
//  Created by Jakub Vlasák on 14/09/14.
//  Copyright (c) 2014 Jakub Vlasak. All rights reserved.
//

import UIKit


class ViewController: UIViewController, VJAutocompleteDataSource, VJAutocompleteDelegate, UITextFieldDelegate {
    
    
    // -------------------------------------------------------------------------------
    // MARK: - Public properties
    // -------------------------------------------------------------------------------
    
    // Outlets
    @IBOutlet weak var mainTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    
    
    // -------------------------------------------------------------------------------
    // MARK: - Private properties
    // -------------------------------------------------------------------------------
    var sourceDataArray = [AnyObject]();
    var mainAutocomplete: VJAutocomplete!;
    var secAutocomplete: VJAutocomplete!;
    
    // -------------------------------------------------------------------------------
    // MARK - Lifecycle
    // -------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceDataArray = Country.listOfCountries();
        
        
        mainTextField.tag = 0;
        secondTextField.tag = 1;
        
        // Initialize it with initWithTextField is recomended
        mainAutocomplete = VJAutocomplete(textField: mainTextField);
        secAutocomplete = VJAutocomplete(textField: secondTextField);
        setupAutocomplete();
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK - VJAutocomplete data source
    // -------------------------------------------------------------------------------
    
    func setCell(cell: UITableViewCell, withItem item: AnyObject) -> UITableViewCell {
        cell.textLabel!.text = item as? String;
        cell.textLabel!.font = UIFont.systemFontOfSize(15.0);
        return cell;
    }
    
    func getItemsArrayWithSubstring(substring: String) -> [AnyObject] {
        let beginsWithPredicate = NSPredicate(format: "SELF beginswith[c] %@", substring);
        var searchedCountriesArray  = (sourceDataArray as NSArray).filteredArrayUsingPredicate(beginsWithPredicate);
        return searchedCountriesArray;
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK - VJAutocomplete delegate
    // -------------------------------------------------------------------------------
    
    func autocompleteWasSelectedRow(rowIndex: Int) {
        mainTextField.resignFirstResponder();
        secondTextField.resignFirstResponder();
    }
    
    // -------------------------------------------------------------------------------
    // MARK - UITextField delegate
    // -------------------------------------------------------------------------------

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 0 {
            mainAutocomplete.shouldChangeCharacters(InRange: range, replacementString: string);
        } else {
            secAutocomplete.shouldChangeCharacters(InRange: range, replacementString: string);
        }
        
        return true;
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 0 {
            mainAutocomplete.hideAutocomplete();
        } else {
            secAutocomplete.hideAutocomplete();
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        
        if textField.tag == 0 {
            mainAutocomplete.hideAutocomplete();
        } else {
            secAutocomplete.hideAutocomplete();
        }
        return true;
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            mainAutocomplete.hideAutocomplete();
        } else {
            secAutocomplete.hideAutocomplete();
        }
        return true;
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 0{
            mainTextField.becomeFirstResponder();
        }else{
            secondTextField.becomeFirstResponder();
        }
    }
    
    // -------------------------------------------------------------------------------
    // MARK - Private methods
    // -------------------------------------------------------------------------------
    
    private func setupAutocomplete() {
        mainAutocomplete.autocompleteDataSource = self;
        mainAutocomplete.autocompleteDelegate = self;
        mainAutocomplete.minCountOfCharsToShow = 1;
        mainAutocomplete.maxVisibleRowsCount = 2;
        mainAutocomplete.cellHeight = 32;
        mainAutocomplete.setBorder(1.5, cornerRadius: 8.0, color: UIColor.groupTableViewBackgroundColor());

        secAutocomplete.autocompleteDataSource = self;
        secAutocomplete.autocompleteDelegate = self;
        secAutocomplete.minCountOfCharsToShow = 1;
        secAutocomplete.maxVisibleRowsCount = 2;
        secAutocomplete.cellHeight = 32;
        secAutocomplete.setBorder(1.5, cornerRadius: 8.0, color: UIColor.groupTableViewBackgroundColor());
    }

    
}

