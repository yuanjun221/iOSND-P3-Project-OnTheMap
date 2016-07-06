//
//  OTMPinViewController.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/6.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit
import CoreLocation

class OTMPinViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var locationInputView: UIView!
    
    

}


extension OTMPinViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.layer.cornerRadius = 4.0
        urlTextField.layer.cornerRadius = 4.0
        submitButton.layer.cornerRadius = 4.0
        
        locationInputView.alpha = 0
        
    }
}


extension OTMPinViewController {
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        toggleLocationInputViewBy(locationInputView.alpha)
    }
    
    func toggleLocationInputViewBy(alpha: CGFloat) {
        
        UIView.animateWithDuration(0.25) {
            self.locationInputView.alpha = alpha == 0 ? 0.9 : 0
        }
        self.locationInputView.alpha == 0 ? locationTextField.resignFirstResponder() : locationTextField.becomeFirstResponder()

    }
}


extension OTMPinViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == locationTextField {
            // get the string user input and make a notation on the map
        }
    }
    
}



































