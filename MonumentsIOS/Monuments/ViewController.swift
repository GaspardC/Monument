//
//  ViewController.swift
//  Monuments
//
//  Created by Gaspard Chevassus on 18/06/2016.
//  Copyright © 2016 Gaspard Chevassus. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var myTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.myTextField.delegate = self;

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segueToUpload") {
            let svc = segue.destinationViewController as! UploadPhotoController;
        
            svc.uniqueIdentifier = self.myTextField.text
            
        }
    }

}

