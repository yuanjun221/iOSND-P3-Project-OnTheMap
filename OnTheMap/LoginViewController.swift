//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/6/28.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit


// MARK: - View Controller Properties
class LoginViewController: UIViewController {
    @IBOutlet weak var onTheMapLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInWithLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    
}


// MARK: - View Controller Lifecycle
extension LoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeFromKeyboardNotifications()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}


// MARK: - View Touching Behavior
extension LoginViewController {
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissKeyboardForTextField(emailTextField)
        dismissKeyboardForTextField(passwordTextField)
    }
    
    func dismissKeyboardForTextField(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
}

// MARK: - View Shifting Behavior
extension LoginViewController {
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if passwordTextField.isFirstResponder() {
            view.frame.origin.y = -50
        }
        if emailTextField.isFirstResponder() {
            view.frame.origin.y = 0
        }
        
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubsribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}


// MARK: - TextField Delegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
