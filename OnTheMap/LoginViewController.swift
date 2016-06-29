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

    @IBOutlet weak var udacityImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    
    private var isSocialViewHidden = true
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
        loginButton.layer.cornerRadius = 4.0
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubsribeFromKeyboardNotifications()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
    func keyboardWillShow() {
        setView(withViewOffset: -100, imageViewOffset: -20, signUpButtonAlpha: 0)
    }
    
    func keyboardWillHide() {
        setView(withViewOffset: 0, imageViewOffset: 41, signUpButtonAlpha: 1)
    }
    
    func setView(withViewOffset viewOffset: CGFloat, imageViewOffset: CGFloat, signUpButtonAlpha: CGFloat) {
        view.frame.origin.y = viewOffset
        udacityImageView.frame.origin.y = imageViewOffset
        UIView.animateWithDuration(0.25, animations: {
            self.signUpButton.alpha = signUpButtonAlpha
        })
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubsribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}


// MARK: - Buttons Action
extension LoginViewController {

    @IBAction func toggleSocialView(sender: AnyObject) {
        setSocialViewOffsetBy(isSocialViewHidden)
    }
    
    func setSocialViewOffsetBy(isHidden: Bool) {
        UIView.animateWithDuration(0.3, animations: {
            self.socialView.frame.origin.y += isHidden ? -46 : 46
        })
        isSocialViewHidden = !isHidden
    }
    
}


// MARK: - TextField Delegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
