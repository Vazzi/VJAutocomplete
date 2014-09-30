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
    var doNotShow = true //!< Do not show autocomplete
    
    // Other properties
    var maxVisibleRowsCount:UInt = 2 //!< Maximum height of autocomplete based on max visible rows
    var cellHeight:UInt = 44 //!< Cell height
    var minCountOfCharsToShow:UInt = 3 //!< Minimum count of characters needed to show autocomplete
    
    var autocompleteDataSource:VJAutocompleteDataSource? //!< Manipulation with data
    var autocompleteDelegate:VJAutocompleteDelegate? //!< Manipulation with autocomplete
    
    
    // -------------------------------------------------------------------------------
    // MARK: - Private properties
    // -------------------------------------------------------------------------------
    private let cellIdentifier = "VJAutocompleteCellIdentifier"
    private var lastSubstring:String = "" //!< Last given substring
    private var autocompleteItemsArray = [] //!< Current suggestions
    private var autocompleteSearchQueue = dispatch_queue_create("VJAutocompleteQueue",
        DISPATCH_QUEUE_SERIAL); //!< Queue for searching suggestions
    private var isVisible = false //<! Is autocomplete visible
    
    
}
