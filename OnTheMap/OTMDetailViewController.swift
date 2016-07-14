//
//  OTMDetailViewController.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/11.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class OTMDetailViewController: UIViewController {
    
    var studentIndex: Int!
    private var studentInfo: OTMStudentInformation {
        return OTMClient.sharedInstance().studentsInfo[studentIndex]
    }
    private var isDeleted: Bool = false
    private var urlRequest: NSURLRequest?
    var onDismiss: ((sender: UIViewController) -> Void)!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

}


extension OTMDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        if studentInfo.uniqueKey == OTMClient.sharedInstance().userUniqueKey {
            let deleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(deleteButtonPressed))
            navigationItem.rightBarButtonItem = deleteButton
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationItem.title = "\(studentInfo.firstName) \(studentInfo.lastName)"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if isDeleted {
            onDismiss(sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pushWebView" {
            let webViewController = segue.destinationViewController as! OTMWebViewController
            webViewController.urlRequest = urlRequest!
        }
    }
}


extension OTMDetailViewController {
    func deleteButtonPressed() {
        let alertTitle = "Delete Information"
        let alertMessage = "Are you sure to delete your information from sever?"
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { deleteAction in
            self.deleteUserInfo()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { cancelAction in
            self.setViewWaiting(false)
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}


extension OTMDetailViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 90
        case (1, 0):
            return view.frame.width
        default:
            return 44
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10.0
        } else {
            return 5.0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch (indexPath.section, indexPath.row) {
        case (2, 0):
            return true
        default:
            return false
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            var urlString = studentInfo.mediaURL
            
            if urlString.lowercaseString.hasPrefix("http://") || urlString.lowercaseString.hasPrefix("https://") {
            } else {
                urlString = "http://\(urlString)"
            }
            
            guard let url = NSURL(string: urlString) else {
                presentAlertController(WithTitle: "Invalid URL", message: "\(urlString) is not a valid url", ForHostViewController: self)
                return
            }
            
            urlRequest = NSURLRequest(URL: url)
            performSegueWithIdentifier("pushWebView", sender: tableView)

        }
    }
    
}


extension OTMDetailViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let nameCell = tableView.dequeueReusableCellWithIdentifier("nameCell") as! OTMDetailNameTableViewCell
        let mapViewCell = tableView.dequeueReusableCellWithIdentifier("mapViewCell") as! OTMDetailMapViewTableViewCell
        let urlCell = tableView.dequeueReusableCellWithIdentifier("urlCell") as! OTMDetailUrlTableViewCell
        
        if let avatarImage = studentInfo.avatarImage {
            nameCell.avatarImageView.image = avatarImage
        } else {
            getAvatarImageForNameCell(nameCell)
        }
        
        nameCell.nameLabel.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        nameCell.lastUpdatedLabel.text = "Last updated at: " + "\((studentInfo.updatedAt as NSString).substringToIndex(10)) \((studentInfo.updatedAt as NSString).substringWithRange(NSMakeRange(11, 5)))"
        
        mapViewCell.mapString.text = studentInfo.mapString
        
        if let countryCode = studentInfo.countryCode {
            mapViewCell.flagImageView.image = UIImage(named: countryCode)
        } else {
            getCountryCodeForMapCell(mapViewCell)
        }
        
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: studentInfo.latitude, longitude: studentInfo.longitude)
        annotation.coordinate = coordinate
        mapViewCell.mapView.addAnnotation(annotation)
        mapViewCell.mapView.setCenterCoordinate(coordinate, animated: true)
        
        let region = CLCircularRegion(center: coordinate, radius: 5000, identifier: "Town")
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, region.radius * 2, region.radius * 2)
        mapViewCell.mapView.regionThatFits(coordinateRegion)
        mapViewCell.mapView.setRegion(coordinateRegion, animated: true)
        
        urlCell.urlLabel.text = studentInfo.mediaURL
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return nameCell
        case (1, 0):
            return mapViewCell
        case (2, 0):
            return urlCell
        default:
            return UITableViewCell()
        }
    }
    
}


extension OTMDetailViewController {
    func getAvatarImageForNameCell(nameCell: OTMDetailNameTableViewCell) {
        OTMClient.sharedInstance().getAvatarImageWithStudentInfo(studentInfo) { (image, error) in
            let errorDomain = "Error occurred when getting avatar image: "
                
            guard error == nil else {
                print(errorDomain + error!.localizedDescription)
                return
            }
                
            guard let image = image else {
                print(errorDomain + "No image returned.")
                return
            }
                
            OTMClient.sharedInstance().studentsInfo[self.studentIndex].avatarImage = image
            
            performUIUpdatesOnMain {
                nameCell.avatarImageView.image = image
            }
        }
    }
    
    func getCountryCodeForMapCell(mapCell: OTMDetailMapViewTableViewCell) {
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
                
            OTMClient.sharedInstance().studentsInfo[self.studentIndex].countryCode = countryCode
            
            performUIUpdatesOnMain {
                mapCell.flagImageView.image = UIImage(named: countryCode)
            }
        }
    }
    
    func deleteUserInfo() {
        setViewWaiting(true)
        
        OTMClient.sharedInstance().deleteStudentInfoWithObjectId(studentInfo.objectID) { (success, error) in
            
            performUIUpdatesOnMain {
                self.setViewWaiting(false)
            }
            
            if success {
                self.isDeleted = true
                
                performUIUpdatesOnMain {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            } else {
                print(error!.localizedDescription)
                performUIUpdatesOnMain {
                    presentAlertController(WithTitle: "Delete Information Failed", message: "Connection timed out.", ForHostViewController: self)
                }
            }

        }
    }
    
    func setViewWaiting(indicator: Bool) {
        UIView.animateWithDuration(0.25) {
            self.view.backgroundColor = indicator ? UIColor.blackColor() : UIColor.whiteColor()
            self.tableView.alpha = indicator ? 0.6 : 1.0
            self.navigationItem.rightBarButtonItem?.enabled = !indicator
        }
        indicator ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

}
