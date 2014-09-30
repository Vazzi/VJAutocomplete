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
