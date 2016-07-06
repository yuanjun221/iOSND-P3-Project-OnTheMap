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
    
    var studentsInfo: [OTMStudentInformation] {
        return OTMClient.sharedInstance().studentsInfo
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
}


// MARK: - View Controller Life Cycle
extension OTMMapViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if studentsInfo.isEmpty {
            getStudentsInformation()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}


// MARK: - Buttons Action
extension OTMMapViewController {
    
    @IBAction func refresh(sender: AnyObject) {
        getStudentsInformation()
    }
    
}


// MARK: - MKMapViewDelegate
extension OTMMapViewController: MKMapViewDelegate {
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //        if control == annotationView.rightCalloutAccessoryView {
    //            let app = UIApplication.sharedApplication()
    //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //        }
    //    }
}


// MARK: - Get Students Information
extension OTMMapViewController {
    
    func getStudentsInformation() {
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(self.mapView.annotations)
        }
        setViewWaiting(true)

        OTMClient.sharedInstance().getStudentsInformation { (studentsInfo, error) in
            let errorDomain = "Error occurred when getting students Information: "
            guard error == nil else {
                print(errorDomain +  error!.localizedDescription)
                performUIUpdatesOnMain {
                    self.setViewWaiting(false)
                    presentAlertControllerWithTitle("Fetching Data Failed", message: "Error occurred when getting students Information", FromHostViewController: self)
                }
                return
            }
            
            guard let studentsInfo = studentsInfo else {
                print(errorDomain + "No students information returned.")
                return
            }
            
            OTMClient.sharedInstance().studentsInfo = studentsInfo
            
            var annotations = [MKPointAnnotation]()
            
            for info in studentsInfo {
                let latitude = CLLocationDegrees(info.latitude)
                let longitude = CLLocationDegrees(info.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let firstName = info.firstName
                let lastName = info.lastName
                let mediaURL = info.mediaURL
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                annotations.append(annotation)
            }
            
            performUIUpdatesOnMain {
                self.mapView.addAnnotations(annotations)
                self.setViewWaiting(false)
            }
        }
    }
    
    func setViewWaiting(indicator: Bool) {
        UIView.animateWithDuration(0.25, animations: {
            self.view.backgroundColor = indicator ? UIColor.blackColor() : UIColor.whiteColor()
            self.mapView.alpha = indicator ? 0.6 : 1.0
            self.refreshButton.enabled = !indicator
        })
        indicator ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
    }
    
}