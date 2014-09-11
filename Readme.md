VJAutocomplete
===================
Autocomplete for iOS applications using UITextField. 

About
--------
It is a basic autocomplete that helps user with writing. Very simmilr to classic web autocompletes.

Writen in Objective-C and also beeing rewriting to Swift (Will be here soon).

This repository has _VJAutocomplete_ writen in Objective-C in the directory _VJAutocomplete_ObjC_, then _VJAutocomplete_Swift_ (Comming soon) and _VJAutocompleteDemo_ project for you to see how it works. 

How it works
--------
_VJAutocomplete_ table for text field is pinned to the text field that must be given. User starts writing to the text field and _VJAutocomplete_ show if has any suggestion. If there is no suggestion then hide. User can choose suggestion by clicking on it. If user choose any suggestion then it diseppeared and add text to text field. If user continues adding text then _VJAutocomplete_ start showing another suggestions or diseppead if has no.

_VJAutocomplete_ inherits from UITableView.

If user is writing and text is the same as before (plus some characters) and it had no suggestions before then do not search for suggestions. It is really helpful if we do not want to ask for data too much. For example if there is too much source data to filter.

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

### Optional settings ######

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


