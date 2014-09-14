//
//  ViewController.swift
//  VJAutocompleteSwiftDemo
//
//  Created by Jakub Vlasák on 14/09/14.
//  Copyright (c) 2014 Jakub Vlasak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   // Outlets
    @IBOutlet weak var mainTextField: UITextField!
    
    
    // -------------------------------------------------------------------------------
    // MARK - Lifecycle
    // -------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTextField.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

