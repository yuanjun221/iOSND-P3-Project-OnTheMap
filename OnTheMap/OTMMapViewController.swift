//
//  OTMMapViewController.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/1.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit
import MapKit


// MARK: - View Controller Properties
class OTMMapViewController: UIViewController {
    
    // Properties
    var studentsInfo: [OTMStudentInformation] {
        return OTMClient.sharedInstance().studentsInfo
    }
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pinButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
}


// MARK: - View Controller Life Cycle
extension OTMMapViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if studentsInfo.isEmpty {
            getStudentsInformation()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
            let annotations = annotationsFromStudentsInfo(studentsInfo)
            mapView.addAnnotations(annotations)
        }

    }
        
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pinOnMap" {
            let pinNavigationController = segue.destinationViewController as! OTMPinNavigationController
            let pinViewController = pinNavigationController.topViewController as! OTMPinViewController
            pinViewController.onDismiss = { sender in
                self.getStudentsInformation()
            }
        }
        
        if segue.identifier == "pushDetailView" {
            let detailViewController = segue.destinationViewController as! OTMDetailViewController
            detailViewController.studentIndex = ((sender as! MKAnnotationView).annotation as! OTMMKPointAnnotation).studentIndex
            detailViewController.onDismiss = { sender in
                self.getStudentsInformation()
            }
        }

    }
    
    func annotationsFromStudentsInfo(studentsInfo: [OTMStudentInformation]) -> [OTMMKPointAnnotation] {
        var annotations = [OTMMKPointAnnotation]()
        
        for index in 0..<studentsInfo.count {
            let studentInfo = studentsInfo[index]
            let latitude = CLLocationDegrees(studentInfo.latitude)
            let longitude = CLLocationDegrees(studentInfo.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let firstName = studentInfo.firstName
            let lastName = studentInfo.lastName
            let mediaURL = studentInfo.mediaURL
            
            let annotation = OTMMKPointAnnotation()
            annotation.studentIndex = index
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        return annotations
    }
}


// MARK: - View Response Behavior
extension OTMMapViewController {
    func setViewWaiting(indicator: Bool) {
        UIView.animateWithDuration(0.25) {
            self.view.backgroundColor = indicator ? UIColor.blackColor() : UIColor.whiteColor()
            self.mapView.alpha = indicator ? 0.6 : 1.0
            self.refreshButton.enabled = !indicator
        }
        indicator ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
    }
    
    func setViewWatingWhileLogout(indicator: Bool) {
        UIView.animateWithDuration(0.25) {
            self.logoutButton.enabled = !indicator
            self.pinButton.enabled = !indicator
            setTabBarItemsEnabled(indicator, ForTabBarController: self.tabBarController!)
        }
        setViewWaiting(indicator)
    }
}


// MARK: - Buttons Action
extension OTMMapViewController {
    @IBAction func refresh(sender: AnyObject) {
        getStudentsInformation()
    }
    
    @IBAction func pinButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("pinOnMap", sender: sender)
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        presentAlertControllerWhileLogoutForhostViewController(self) {
            self.logoutOfUdacity()
        }
    }
}


// MARK: - MKMapView Delegate
extension OTMMapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("pushDetailView", sender: view)
        }
    }
}


// MARK: - Network Request
extension OTMMapViewController {
    func getStudentsInformation() {
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
        setViewWaiting(true)

        OTMClient.sharedInstance().getStudentsInformation { (studentsInfo, error) in
            let errorDomain = "Error occurred when getting students Information: "
            guard error == nil else {
                print(errorDomain +  error!.localizedDescription)
                performUIUpdatesOnMain {
                    self.setViewWaiting(false)
                    presentAlertController(WithTitle: "Fetching Data Failed", message: "Error occurred when getting students Information", ForHostViewController: self)
                }
                return
            }
            
            guard let studentsInfo = studentsInfo else {
                print(errorDomain + "No students information returned.")
                return
            }
            
            OTMClient.sharedInstance().studentsInfo = studentsInfo
            
            let annotations = self.annotationsFromStudentsInfo(studentsInfo)
            
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(annotations)
                self.setViewWaiting(false)
            }
            
            self.getStudentsAvatarAndCountryCodeWithStudentsInfo(studentsInfo)
        }
    }
    
    func getStudentsAvatarAndCountryCodeWithStudentsInfo(studentsInfo: [OTMStudentInformation]) {
        for index in 0..<studentsInfo.count {
            let studentInfo = studentsInfo[index]
            
            if studentInfo.avatarImage == nil {
                OTMClient.sharedInstance().getAvatarImageWithUniqueKey(studentInfo.uniqueKey) { (image, error) in
                    let errorDomain = "Error occurred when getting avatar image: "
                    
                    guard error == nil else {
                        print(errorDomain + error!.localizedDescription)
                        return
                    }
                    
                    guard let image = image else {
                        print(errorDomain + "No image returned.")
                        return
                    }
                    
                    OTMClient.sharedInstance().studentsInfo[index].avatarImage = image
                }
            }
            
            if studentInfo.countryCode == nil {
                OTMClient.sharedInstance().getCountryCodeWithStudentInfo(studentInfo) { (countryCode, error) in
                    let errorDomain = "Error occurred when getting country code: "
                    guard error == nil else {
                        print(errorDomain + error!.localizedDescription)
                        return
                    }
                    
                    guard let countryCode = countryCode else {
                        print(errorDomain + "No country code returned.")
                        return
                    }
                    
                    OTMClient.sharedInstance().studentsInfo[index].countryCode = countryCode
                }
            }
        }
    }
    
    func logoutOfUdacity() {
        setViewWatingWhileLogout(true)
        
        OTMClient.sharedInstance().logoutOfUdacity { (success, error) in
            
            performUIUpdatesOnMain {
                self.setViewWatingWhileLogout(false)
            }
            
            if success {
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                print(error!.localizedDescription)
                performUIUpdatesOnMain {
                    presentAlertController(WithTitle: "Logout Failed.", message: "Connection timed out.", ForHostViewController: self)
                }
            }
        }
    }
}