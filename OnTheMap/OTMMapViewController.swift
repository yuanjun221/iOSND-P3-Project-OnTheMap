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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
}


// MARK: - View Controller Life Cycle
extension OTMMapViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentsInformation()
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
            if let studentsInfo = studentsInfo {
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
            } else {
                print(error)
                performUIUpdatesOnMain {
                    self.setViewWaiting(false)
                    presentAlertControllerWithTitle("Fetching Data Failed.", message: nil, FromHostViewController: self)
                }

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