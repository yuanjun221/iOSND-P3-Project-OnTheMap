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

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var urlInputView: UIView!
    
    private var dismissButton: UIBarButtonItem!
    private var searchButton: UIBarButtonItem!

    private var annotation = MKPointAnnotation()
    private var coordinate: CLLocationCoordinate2D?

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
                self.searchButton.enabled = false
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if urlTextField.isFirstResponder() {
            view.frame.origin.y = 0
            UIView.animateWithDuration(0.25) {
                self.searchButton.enabled = true
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


// MARK: - Buttons Action
extension OTMPinViewController {
    @IBAction func dismissPressed(sender: AnyObject) {
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
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchBar.text!, inRegion: nil) { (placemarks, error) in
            guard error == nil else {
                presentAlertControllerWithTitle("Cannot find a location.", message: nil, FromHostViewController: self)
                print(error?.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks else {
                presentAlertControllerWithTitle("Cannot find a location.", message: nil, FromHostViewController: self)
                return
            }
            
            let placemark = placemarks[0]
            
            guard let location = placemark.location else {
                presentAlertControllerWithTitle("Cannot find a location.", message: nil, FromHostViewController: self)
                return
            }
            
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
}


// MARK: - TextField Delegate
extension OTMPinViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        
        
        
        
        
        
        return true
    }
    

}


extension OTMPinViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}



































