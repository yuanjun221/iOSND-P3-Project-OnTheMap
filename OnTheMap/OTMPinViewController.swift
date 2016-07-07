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

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var locationInputView: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var annotation = MKPointAnnotation()
    private var coordinate: CLLocationCoordinate2D?

}


// MARK: - View Controller Lifecycle
extension OTMPinViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
        urlTextField.delegate = self
        
        self.mapView.addAnnotation(annotation)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        locationTextField.layer.cornerRadius = 4.0
        urlTextField.layer.cornerRadius = 4.0
        
        locationInputView.alpha = 0
        
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
        if locationTextField.isFirstResponder() {
            locationTextField.resignFirstResponder()
            UIView.animateWithDuration(0.25) {
                self.locationInputView.alpha = 0
            }
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
            searchButton.enabled = false
        }

    }
    
    func keyboardWillHide(notification: NSNotification) {
        if urlTextField.isFirstResponder() {
            view.frame.origin.y = 0
            searchButton.enabled = true
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


// MARK: - TextField Delegate
extension OTMPinViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == locationTextField {
            UIView.animateWithDuration(0.25) {
                self.locationInputView.alpha = 0
            }
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(textField.text!, inRegion: nil) { (placemarks, error) in
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
                
                if let region = placemark.region as? CLCircularRegion {
                    self.coordinate = region.center
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(region.center, region.radius * 2, region.radius * 2)
                    self.mapView.regionThatFits(coordinateRegion)
                    self.mapView.setRegion(coordinateRegion, animated: true)
                }
                
            }
        }
        

        textField.resignFirstResponder()
        
        return true
    }
    
}



































