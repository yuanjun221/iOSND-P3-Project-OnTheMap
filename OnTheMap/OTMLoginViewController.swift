//
//  OTMLoginViewController.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/6/28.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit


// MARK: - View Controller Properties
class OTMLoginViewController: UIViewController {
    
    // MARK: Properties
    private var isSocialLoginViewHidden = false
    private var iscredentialLoginViewShifted = false
    private var isViewWating = false
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
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
extension OTMLoginViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        loginButton.layer.cornerRadius = 4.0
        hideSocialLoginViewBy(isSocialLoginViewHidden)
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
extension OTMLoginViewController {
    
    @IBAction func tapView(sender: AnyObject) {
        if !isViewWating {
            dismissKeyboardForTextField(emailTextField)
            dismissKeyboardForTextField(passwordTextField)
            
            if iscredentialLoginViewShifted {
                moveUpCredentialLoginView(false)
            }
        }
    }
    
    func dismissKeyboardForTextField(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
}

// MARK: - View Moving Behavior
extension OTMLoginViewController {
    func keyboardWillShow() {
        if !iscredentialLoginViewShifted {
            moveUpCredentialLoginView(true)
        }
    }
    
    func moveUpCredentialLoginView(enable: Bool) {
        credentialLoginViewTop.constant = enable ? -120 : -20
        logoImageViewTop.constant = enable ? -10 : 42
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
            self.signUpButton.alpha = enable ? 0 : 1
        })
        iscredentialLoginViewShifted = enable
    }
}


// MARK: - Buttons Action
extension OTMLoginViewController {

    @IBAction func toggleSocialView(sender: AnyObject) {
        hideSocialLoginViewBy(isSocialLoginViewHidden)
    }
    
    func hideSocialLoginViewBy(isHidden: Bool) {
        socialLoginViewBottom.constant = isHidden ? 0 : 45
        
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
        })
        isSocialLoginViewHidden = !isHidden
    }
    
    @IBAction func login(sender: AnyObject) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            presentAlertControllerWithTitle("Login Failed", message: "Empty Email or Password.", FromHostViewController: self)
        } else {
            setUIEnabled(false)
            
            OTMClient.sharedInstance().loginWithCredential(emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                }
                
                if success {
                    let tabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                    self.presentViewController(tabBarController, animated: true, completion: nil)
                } else {
                    presentAlertControllerWithTitle("Login Failed", message: errorString!, FromHostViewController: self)
                }
            }
        }
    }
        
    func setUIEnabled(enabled: Bool) {
        isViewWating = !enabled
        
        emailTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        
        let alpha = CGFloat(enabled ? 1.0 : 0.6)
        UIView.animateWithDuration(0.25, animations: {
            self.emailTextField.alpha = alpha
            self.passwordTextField.alpha = alpha
            self.loginButton.alpha = alpha
        })

        loginButton.setTitle(enabled ? "Login" : nil, forState: .Normal)
        signUpButton.enabled = enabled
        toggleSocialViewButton.enabled = enabled
        facebookButton.enabled = enabled
        
        !enabled ? activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
    }
}


// MARK: - TextField Delegate
extension OTMLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
