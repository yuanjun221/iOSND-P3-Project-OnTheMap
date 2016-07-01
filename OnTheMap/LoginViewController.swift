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
    
    // MARK: Properties
    private var isSocialLoginViewHidden = false
    
    // MARK: Outlets
    @IBOutlet weak var udacityImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var socialView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toggleSocialViewButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    // MARK: Layout Constraints
    @IBOutlet weak var credentialLoginViewTop: NSLayoutConstraint!
    @IBOutlet weak var socialLoginViewBottom: NSLayoutConstraint!
    @IBOutlet weak var logoImageViewTop: NSLayoutConstraint!
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        loginButton.layer.cornerRadius = 4.0
        setSocialLoginViewBottomOffsetBy(isSocialLoginViewHidden)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
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
            setView(withViewOffset: -20, imageViewOffset: 42, signUpButtonAlpha: 1)
        }
    }
}

// MARK: - View Shifting Behavior
extension LoginViewController {
    func keyboardWillShow() {
        setView(withViewOffset: -120, imageViewOffset: -10, signUpButtonAlpha: 0)
    }
    
    func setView(withViewOffset viewOffset: CGFloat, imageViewOffset: CGFloat, signUpButtonAlpha: CGFloat) {
        credentialLoginViewTop.constant = viewOffset
        logoImageViewTop.constant = imageViewOffset
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
            self.signUpButton.alpha = signUpButtonAlpha
        })
    }
}


// MARK: - Buttons Action
extension LoginViewController {

    @IBAction func toggleSocialView(sender: AnyObject) {
        setSocialLoginViewBottomOffsetBy(isSocialLoginViewHidden)
    }
    
    func setSocialLoginViewBottomOffsetBy(isHidden: Bool) {
        socialLoginViewBottom.constant = isHidden ? 0 : socialView.frame.height - toggleSocialViewButton.frame.height
        
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
        })
        isSocialLoginViewHidden = !isSocialLoginViewHidden
    }
    
    
    @IBAction func login(sender: AnyObject) {
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            presentAlertViewControllerWithMessage("Empty Email or Password.")
        } else {
            setUIEnabled(false)
            activityIndicator.startAnimating()
            
            OTMClient.sharedInstance().loginWithCredential(emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.activityIndicator.stopAnimating()
                    if success {
                        let tabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                        self.presentViewController(tabBarController, animated: true, completion: nil)
                    } else {
                        self.presentAlertViewControllerWithMessage(errorString!)
                    }
                }
            }
        }
    }
    
    func presentAlertViewControllerWithMessage(message: String) {
        let alertController = UIAlertController(title: "Login Failed", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setUIEnabled(enabled: Bool) {
        emailTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        loginButton.alpha = enabled ? 1.0 : 0.6
        loginButton.setTitle(enabled ? "Login" : nil, forState: .Normal)
        signUpButton.enabled = enabled
        toggleSocialViewButton.enabled = enabled
        facebookButton.enabled = enabled
    }
    
}


// MARK: - TextField Delegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
