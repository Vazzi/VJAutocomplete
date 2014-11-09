VJAutocomplete
===================
Autocomplete for iOS applications. 

![Alt text](/autocompleteDemo.gif "Demo")

About
--------
It is a basic autocomplete that helps user with writing. Very simmilar to classic web autocompletes.

Written in Objective-C and Swift. You can choose which one to use.


How it works
--------
_VJAutocomplete_ is a table pinned to UITextField. 
*Text field is created by developer not autocomplete.*

User starts writing to the text field and _VJAutocomplete_ show if has any suggestion. If there is no suggestion then hide. User can choose suggestion by clicking on it. If any suggestion is cliced then autocomplete disappear and text is added to text field.

_VJAutocomplete_ inherits from UITableView.

If user is writing and text is the same as before (plus some characters) and it had no suggestions before then it does not search for suggestions. It is really helpful if we do not want to ask for data too much.

Usage
--------
1. Add _VJAutocomplete.h_ and _VJAutocomplete.m_ to your project
2. Make sure you have some UITextField 
3. Implement methods of _VJAutocompleteDataSource_ protocol
4. Initialize _VJAutocomplete_ in a controller or view

    ```VJAutocomplete *mainAutocomplete = [[VJAutocomplete alloc] initWithTextField:self.mainTextField];```

    *Use only `initWithTextField:` to initialize _VJAutocomplete_.*

5. Set the _autocompleteDataSource_ property to a valid object that implements the required methods of the _VJAutocompleteDataSource_ protocol

    ```[mainAutocomplete setAutocompleteDataSource:self];```

6. Set delegate of UITextField and implement this method

    ```
    - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
    {
        [self.mainAutocomplete shouldChangeCharactersInRange:range replacementString:string];
        return YES;
    }
    ```

### Optional ######

- Call `[self.mainAutocomplete hideAutocomplete]` if you want to hide autocomplete
- Set `minCountOfCharsToShow` property to set number of characters needed to be written to show autocomplete
- Set `maxVisibleRowsCount` property for minimum visible rows (This also defines height of autocomplete table)
- Set `doNotShow` property to disable autocomplete

License
--------
_VJAutocomplete_ uses the MIT License.

Credits
--------
_VJAutocomplete_ was written by Jakub Vlasak


