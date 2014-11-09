//
//  VJAutocomplete.m
//
//  Created by Jakub Vlasák on 14/09/14.
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

import UIKit

/*! Protocol for manipulation with data
*/
protocol VJAutocompleteDataSource {
    /*! Set the text of cell with given data. Data can be any object not only string.
    Always return the parameter cell. Only set text. ([cell.textLabel setText:])
    /param cell
    /param item Source data. Data can be any object not only string that is why you have to define the cell text.
    /return cell that has been given and modified
    */
    func setCell(cell:UITableViewCell, withItem item:AnyObject) -> UITableViewCell
    
    /*! Define data that should by shown by autocomplete on substring. Can be any object. Not only NSString.
    /param substring
    /return array of objects for substring
    */
    func getItemsArrayWithSubstring(substring:String) -> [AnyObject]
    
}


/*! Protocol for manipulation with VJAutocomplete
*/
protocol VJAutocompleteDelegate {
    
    /*! This is called when row was selected and autocomplete add text to text field.
    /param rowIndex Selected row number
    */
    func autocompleteWasSelectedRow(rowIndex: Int)
    
}


/*! VJAutocomplete table for text field is pinned to the text field that must be given. User starts
writing to the text field and VJAutocomplete show if has any suggestion. If there is no
suggestion then hide. User can choose suggestion by clicking on it. If user choose any suggestion
then it diseppeared and add text to text field. If user continues adding text then
VJAutocomplete start showing another suggestions or diseppead if has no.
*/
class VJAutocomplete: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    
    // -------------------------------------------------------------------------------
    // MARK: - Public properties
    // -------------------------------------------------------------------------------
    
    // Set by init
    var textField: UITextField! //!< Given text field. To this text field is autocomplete pinned to.
    var parentView: UIView? //!< Parent view of text field (Change only if the current view is not what you want)
    
    // Actions properties
    var doNotShow = false //!< Do not show autocomplete
    
    // Other properties
    var maxVisibleRowsCount:UInt = 2 //!< Maximum height of autocomplete based on max visible rows
    var cellHeight:CGFloat = 44.0 //!< Cell height
    var minCountOfCharsToShow:UInt = 3 //!< Minimum count of characters needed to show autocomplete
    
    var autocompleteDataSource:VJAutocompleteDataSource? //!< Manipulation with data
    var autocompleteDelegate:VJAutocompleteDelegate? //!< Manipulation with autocomplete
    
    
    // -------------------------------------------------------------------------------
    // MARK: - Private properties
    // -------------------------------------------------------------------------------
    private let cellIdentifier = "VJAutocompleteCellIdentifier"
    private var lastSubstring:String = "" //!< Last given substring
    private var autocompleteItemsArray = [AnyObject]() //!< Current suggestions
    private var autocompleteSearchQueue = dispatch_queue_create("VJAutocompleteQueue",
        DISPATCH_QUEUE_SERIAL); //!< Queue for searching suggestions
    private var isVisible = false //<! Is autocomplete visible
    
    // -------------------------------------------------------------------------------
    // MARK: - Init methods
    // -------------------------------------------------------------------------------
    
    init(textField: UITextField) {
        super.init(frame: textField.frame, style: UITableViewStyle.Plain);
        // Text field
        self.textField = textField;
        // Set parent view as text field super view
        self.parentView = textField.superview;
        // Setup table view
        setupTableView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK: - Setups
    // -------------------------------------------------------------------------------
    
    private func setupTableView() {
        // Protocols
        dataSource = self;
        delegate = self;
        
        // Properties
        scrollEnabled = true;
        
        // Visual properties
        backgroundColor = UIColor.whiteColor();
        rowHeight = cellHeight;
        
        // Empty footer
        tableFooterView = UIView(frame: CGRectZero);
        
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK: - Public methods
    // -------------------------------------------------------------------------------
    
    func setBorder(width: CGFloat, cornerRadius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width;
        self.layer.cornerRadius = cornerRadius;
        self.layer.borderColor = color.CGColor;
    }
    
    func searchAutocompleteEntries(WithSubstring substring: NSString) {
        let lastCount = autocompleteItemsArray.count;
        autocompleteItemsArray.removeAll(keepCapacity: false);
        
        // If substring has less than min. characters then hide and return
        if (UInt(substring.length) < minCountOfCharsToShow) {
            hideAutocomplete();
            return;
        }
        
        let substringBefore = lastSubstring;
        lastSubstring = substring;
        // If substring is the same as before and before it has no suggestions then
        // do not search for suggestions
        if (substringBefore == substring.substringToIndex(substring.length - 1) &&
            lastCount == 0 &&
            !substringBefore.isEmpty) {
            return;
        }

        dispatch_async(autocompleteSearchQueue) { ()
            // Save new suggestions
            if let dataArray = self.autocompleteDataSource?.getItemsArrayWithSubstring(substring) {
                self.autocompleteItemsArray = dataArray;
            }
            // Call show or hide autocomplete and reload data on main thread
            dispatch_async(dispatch_get_main_queue()) { ()
                if (self.autocompleteItemsArray.count != 0) {
                    self.showAutocomplete();
                } else {
                    self.hideAutocomplete();
                }
                self.reloadData();
            }
        }
        
    }
    
    
    func hideAutocomplete() {
        if (!isVisible) {
            return;
        }
        removeFromSuperview();
        isVisible = false;
    }
    
    func showAutocomplete() {
        if (doNotShow) {
            return;
        }
        
        if (isVisible) {
            removeFromSuperview();
        }
        self.isVisible = true;
        
        var origin = getTextViewOrigin();
        setFrame(origin, height: computeHeight());

        layer.zPosition = CGFloat.max;
        
        parentView?.addSubview(self);
        
    }
    
    func shouldChangeCharacters(InRange range: NSRange, replacementString string: NSString) {
        var substring = NSString(string: textField.text);
        substring = substring.stringByReplacingCharactersInRange(range, withString: string);
        searchAutocompleteEntries(WithSubstring: substring);
    }
    
    func isAutocompleteVisible() -> Bool {
        return isVisible;
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK: - UITableView data source
    // -------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteItemsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell!;
        if let oldCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell {
            cell = oldCell;
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier);
        }
        
        var newCell = autocompleteDataSource?.setCell(cell, withItem: autocompleteItemsArray[indexPath.row])
        return cell
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK: - UITableView delegate
    // -------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get the cell
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        // Set text to
        textField.text = selectedCell?.textLabel.text
        // Call delegate method
        autocompleteDelegate?.autocompleteWasSelectedRow(indexPath.row)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    

    // -------------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------------
    
    private func computeHeight() -> CGFloat {
        // Set number of cells (do not show more than maxSuggestions)
        var visibleRowsCount = autocompleteItemsArray.count as NSInteger;
        if (visibleRowsCount > NSInteger(maxVisibleRowsCount)) {
            visibleRowsCount = NSInteger(maxVisibleRowsCount);
        }
        // Calculate autocomplete height
        let height = cellHeight * CGFloat(visibleRowsCount);
        
        return height;
    }
    
    private func getTextViewOrigin() -> CGPoint {
        var textViewOrigin: CGPoint;
        if (parentView?.isEqual(textField.superview) != nil) {
            textViewOrigin = textField.frame.origin;
        } else {
            textViewOrigin = textField.convertPoint(textField.frame.origin,
                toView: parentView);
        }
        return textViewOrigin;
    }

    private func setFrame(textViewOrigin: CGPoint, height: CGFloat) {
        var newFrame = CGRectMake(textViewOrigin.x, textViewOrigin.y + CGRectGetHeight(textField.bounds),
            CGRectGetWidth(textField.bounds), height);
        frame = newFrame;
    }


}

