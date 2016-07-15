//
//  OTMPinViewController.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/6.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


// MARK: - View Controller Properties
class OTMPinViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: Properties
    var onDismiss: (() -> Void)!
    
    private var dismissButton: UIBarButtonItem!
    private var searchButton: UIBarButtonItem!
    
    private var annotation = MKPointAnnotation()
    private var currentValidMapString: String!
    private var coordinate: CLLocationCoordinate2D?
    
    // MARK: Outlets
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var urlInputView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}


// MARK: - View Controller Lifecycle
extension OTMPinViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.delegate = self
        
        dismissButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(dismissPressed))
        dismissButton.tintColor = UIColor.whiteColor()
        
        searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(searchPressed))
        searchButton.tintColor = UIColor.whiteColor()
        
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        urlTextField.layer.cornerRadius = 4.0
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
}


// MARK: - View Touching Behavior
extension OTMPinViewController {
    @IBAction func tapMapView(sender: AnyObject) {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
        
        if urlTextField.isFirstResponder() {
            urlTextField.resignFirstResponder()
        }
    }
}


// MARK: - View Moving Behavior
extension OTMPinViewController {
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if urlTextField.isFirstResponder() {
            view.frame.origin.y = getKeyboardHeight(notification) * -1
            UIView.animateWithDuration(0.25) {
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if urlTextField.isFirstResponder() {
            view.frame.origin.y = 0
            UIView.animateWithDuration(0.25) {
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
            
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}


// MARK: - View Response Behavior
extension OTMPinViewController {
    func setViewWaiting(indicator: Bool) {
        UIView.animateWithDuration(0.25) {
            self.view.backgroundColor = indicator ? UIColor.blackColor() : UIColor.whiteColor()
            self.mapView.alpha = indicator ? 0.6 : 1.0
            self.navigationItem.rightBarButtonItem?.enabled = !indicator
            self.urlTextField.enabled = !indicator
        }
        indicator ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}


// MARK: - Buttons Action
extension OTMPinViewController {
    @IBAction func dismissPressed(sender: AnyObject) {
        if urlTextField.isFirstResponder() {
            urlTextField.resignFirstResponder()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.titleView = self.searchBar
        
        searchBar.becomeFirstResponder()
    }
}


// MARK: - SearchBar Delegate
extension OTMPinViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)

        UIView.animateWithDuration(0.25, animations: { searchBar.alpha = 0 }, completion: { finished in
            self.navigationItem.titleView = nil
            self.navigationItem.leftBarButtonItem = self.dismissButton
            self.navigationItem.rightBarButtonItem = self.searchButton
        })
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        geoCodeAddress()
    }
}


// MARK: - TextField Delegate
extension OTMPinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        uploadInfo()
        return true
    }
}


// MARK: - Search Display Controller Table View Delegate & Data Source
extension OTMPinViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}


// MARK: - Network Request
extension OTMPinViewController {
    func geoCodeAddress() {
        setViewWaiting(true)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchBar.text!, inRegion: nil) { (placemarks, error) in
            
            self.setViewWaiting(false)
            
            guard error == nil else {
                presentAlertController(WithTitle: "Cannot find the location.", message: nil, ForHostViewController: self)
                print(error!.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks else {
                presentAlertController(WithTitle: "Cannot find the location.", message: nil, ForHostViewController: self)
                return
            }
            
            let placemark = placemarks[0]
            
            guard let location = placemark.location else {
                presentAlertController(WithTitle: "Cannot find the location.", message: nil, ForHostViewController: self)
                return
            }
            
            self.currentValidMapString = self.searchBar.text!
            
            UIView.animateWithDuration(0.25) {
                self.annotation.coordinate = location.coordinate
            }
            
            if self.mapView.annotations.isEmpty {
                self.mapView.addAnnotation(self.annotation)
            }
            
            if let region = placemark.region as? CLCircularRegion {
                self.coordinate = region.center
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(region.center, region.radius * 2, region.radius * 2)
                self.mapView.regionThatFits(coordinateRegion)
                self.mapView.setRegion(coordinateRegion, animated: true)
            }
        }
    }
    
    func uploadInfo() {
        guard let coordinate = coordinate else {
            presentAlertController(WithTitle:"Empty Location", message: "Please specify a location First.", ForHostViewController: self)
            return
        }
        
        guard let uniqueKey = OTMModel.sharedInstance().userUniqueKey else {
            presentAlertController(WithTitle:"No User Logged In", message: "Please check your loggin information.", ForHostViewController: self)
            return
        }
        
        setViewWaiting(true)
        
        OTMClient.sharedInstance().queryStudentInfoWithUniqueKey(uniqueKey) { (userInfo, error) in
            let errorDomain = "Error occurred when querying user information: "
            
            if let error = error {
                // user information not in data base
                if error.code == -2000 {
                    OTMClient.sharedInstance().getUserNameWithUniqueKey(uniqueKey) { (name, error) in
                        guard error == error else {
                            print(error!.localizedDescription)
                            performUIUpdatesOnMain {
                                self.setViewWaiting(false)
                                presentAlertController(WithTitle: "Create Information Failed", message: "Connection timed out.", ForHostViewController: self)
                            }
                            return
                        }
                        
                        self.postUserLocation(WithUniqueKey: uniqueKey, name: name!, coordinate: coordinate)
                    }
                } else {
                    print(errorDomain + error.localizedDescription)
                    performUIUpdatesOnMain {
                        self.setViewWaiting(false)
                        presentAlertController(WithTitle: "Query Information Failed", message: "Connection timed out.", ForHostViewController: self)
                    }
                    return
                }
                
            } else {
                let alertTitle = "Overwrite Information"
                let alertMessage = "You have already posted a location. Would you like to overwrite it?"
                let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
                
                let overwriteAction = UIAlertAction(title: "Overwrite", style: .Destructive) { overwriteAction in
                    self.putUserLocation(WithUserInfo: userInfo!, coordinate: coordinate)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { cancelAction in
                    performUIUpdatesOnMain {
                        self.setViewWaiting(false)
                    }
                }
                
                alertController.addAction(overwriteAction)
                alertController.addAction(cancelAction)
                
                performUIUpdatesOnMain {
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    func postUserLocation(WithUniqueKey uniqueKey: String, name: (String, String), coordinate: CLLocationCoordinate2D) {
        OTMClient.sharedInstance().postStudentLocation(WithUniqueKey: uniqueKey, name: name, mapString: self.currentValidMapString, mediaUrl: self.urlTextField.text!, coordinate: coordinate) { (success, error) in
            
            performUIUpdatesOnMain {
                self.setViewWaiting(false)
            }
            
            if success {
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(true) {
                        self.onDismiss()
                    }
                }
            } else {
                print(error!.localizedDescription)
                performUIUpdatesOnMain {
                    presentAlertController(WithTitle: "Create Information Failed", message: "Connection timed out.", ForHostViewController: self)
                }
                
            }
        }
    }
    
    func putUserLocation(WithUserInfo userInfo: OTMStudentInformation, coordinate: CLLocationCoordinate2D) {
        OTMClient.sharedInstance().putStudentLocation(WithStudentInfo: userInfo, mapString: self.currentValidMapString, mediaUrl: self.urlTextField.text!, coordinate: coordinate) { (success, error) in
            
            performUIUpdatesOnMain {
                self.setViewWaiting(false)
            }
            
            if success {
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(true) {
                        self.onDismiss()
                    }
                }
            } else {
                print(error!.localizedDescription)
                performUIUpdatesOnMain {
                    presentAlertController(WithTitle: "Update Information Failed", message: "Connection timed out.", ForHostViewController: self)
                }
                
            }
        }
    }
}
