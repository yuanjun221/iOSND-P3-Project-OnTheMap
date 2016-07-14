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
    private var isSocialLoginViewHidden = true
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
        
        socialLoginViewBottom.constant = 45
        isSocialLoginViewHidden = true
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            OTMClient.sharedInstance().FBAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            loginWithFacebookAuthentication()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        loginButton.layer.cornerRadius = 4.0
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
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
            self.signUpButton.alpha = enable ? 0 : 1
        }
        iscredentialLoginViewShifted = enable
    }
}


// MARK: - View Response Behavior
extension OTMLoginViewController {
    func setViewWating(indicator: Bool) {
        isViewWating = indicator
        
        emailTextField.enabled = !indicator
        passwordTextField.enabled = !indicator
        loginButton.enabled = !indicator
        
        let alpha = CGFloat(indicator ? 0.6 : 1.0)
        UIView.animateWithDuration(0.25) {
            self.emailTextField.alpha = alpha
            self.passwordTextField.alpha = alpha
            self.loginButton.alpha = alpha
        }
        loginButton.setTitle(indicator ? nil : "Login", forState: .Normal)
        signUpButton.enabled = !indicator
        toggleSocialViewButton.enabled = !indicator
        facebookButton.enabled = !indicator
        
        indicator ? activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
    }
}


// MARK: - Buttons Action
extension OTMLoginViewController {

    @IBAction func toggleSocialView(sender: AnyObject) {
        hideSocialLoginViewBy(isSocialLoginViewHidden)
    }
    
    func hideSocialLoginViewBy(isHidden: Bool) {
        socialLoginViewBottom.constant = isHidden ? 0 : 45
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
        isSocialLoginViewHidden = !isHidden
    }
    
    @IBAction func login(sender: AnyObject) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            presentAlertController(WithTitle: "Login Failed", message: "Empty Email or Password.", ForHostViewController: self)
        } else {
            loginWithUdacityAccount()
        }
    }
    
    @IBAction func facebookButtonPressed(sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let permissions = ["email"]
        loginManager.logInWithReadPermissions(permissions, fromViewController: self) { (result, error) in
            
            guard error == nil else {
                print(error.localizedDescription)
                presentAlertController(WithTitle: "Login Failed", message: "Cannot login with Facebook Account", ForHostViewController: self)
                return
            }
            
            if result.isCancelled {
                print("User canceled.")
                return
            }
            
            OTMClient.sharedInstance().FBAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            
            self.loginWithFacebookAuthentication()
        }
    }
    
    
    @IBAction func signUpPressed(sender: AnyObject) {
        let urlString = OTMClient.Urls.UdacitySignUpUrl
        let url = NSURL(string: urlString)!
        
        UIApplication.sharedApplication().openURL(url)
    }
}


// MARK: - Text Field Delegate
extension OTMLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - Network Request
extension OTMLoginViewController {
    func loginWithUdacityAccount() {
        setViewWating(true)
        
        OTMClient.sharedInstance().loginWithUdacityCredential(username: emailTextField.text!, password: passwordTextField.text!) { (success, error, errorMessage) in
            
            performUIUpdatesOnMain {
                self.setViewWating(false)
            }
            
            if success {
                performUIUpdatesOnMain {
                    let tabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                    self.presentViewController(tabBarController, animated: true, completion: nil)
                }
                
            } else {
                print(error!.localizedDescription)
                performUIUpdatesOnMain {
                    presentAlertController(WithTitle: "Login Failed", message: errorMessage!, ForHostViewController: self)
                }
            }
        }
    }
    
    func loginWithFacebookAuthentication() {
        guard let accessToken = OTMClient.sharedInstance().FBAccessToken else {
            presentAlertController(WithTitle: "Login Failed", message: "Cannot login with Facebook Account", ForHostViewController: self)
            return
        }
        
        self.setViewWating(true)
        
        OTMClient.sharedInstance().loginWithFacebookAuthentication(accessToken: accessToken) { (success, error, errorMessage) in
            performUIUpdatesOnMain {
                self.setViewWating(false)
            }
            
            if success {
                performUIUpdatesOnMain {
                    let tabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                    self.presentViewController(tabBarController, animated: true, completion: nil)
                }
                
            } else {
                print(error!.localizedDescription)
                performUIUpdatesOnMain {
                    presentAlertController(WithTitle: "Login Failed", message: errorMessage!, ForHostViewController: self)
                }
            }
        }
        
    }
    
}
