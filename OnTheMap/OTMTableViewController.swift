//
//  OTMTableViewController.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/3.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

class OTMTableViewController: UIViewController {
    
    var studentsInfo: [OTMStudentInformation] {
        return OTMClient.sharedInstance().studentsInfo
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}


extension OTMTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
    
}


extension OTMTableViewController {
    @IBAction func refresh(sender: AnyObject) {
        getStudentsInformation()
    }
    
}


extension OTMTableViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let studentInfo = studentsInfo[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! OTMTableViewCell
        
        cell.nameLabel.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        cell.urlLabel.text = studentInfo.mediaURL
        cell.dateLabel.text = (studentInfo.updatedAt as NSString).substringToIndex(10)
        

        // Apple's CLGecoder cannot accept geocoding request more than one per minute.
        // Using google maps gecoding API instead to generate a country code.
        
        OTMClient.sharedInstance().getUserImageUrlFromStudentInfo(studentInfo) { (url, error) in
            let errorDomain = "Error occurred when getting user image url: "
            guard error == nil else {
                print(errorDomain + error!.localizedDescription)
                return
            }
            
            guard let url = url else {
                print(errorDomain + "No url returned.")
                return
            }
            
            OTMClient.sharedInstance().taskForGETImageData(url) { (data, error) in
                let errorDomain = "Error occurred when getting user image data: "
                guard error == nil else {
                    print(errorDomain + error!.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    print(errorDomain + "No image data returned.")
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    print(errorDomain + "No image from image data.")
                    return
                }
                
                performUIUpdatesOnMain {
                    cell.avatarImageView.image = image
                }
            }
        }
        
        guard let countryCode = studentInfo.countryCode else {
            OTMClient.sharedInstance().getCountryCodeFromStudentInfo(studentInfo) { (countryCode, error) in
                let errorDomain = "Error occurred when getting country code: "
                guard error == nil else {
                    print(errorDomain + error!.localizedDescription)
                    return
                }
                
                guard let countryCode = countryCode else {
                    print(errorDomain + "No country code returned.")
                    return
                }
                
                performUIUpdatesOnMain {
                    OTMClient.sharedInstance().studentsInfo[indexPath.row].countryCode = countryCode
                    cell.flagView.image = UIImage(named: countryCode)
                }
            }
            return cell
        }
        
        cell.flagView.image = UIImage(named: countryCode)
        return cell
    }
    
}


extension OTMTableViewController {
    
    func getStudentsInformation() {
        self.setViewWaiting(true)
        OTMClient.sharedInstance().getStudentsInformation { (studentsInfo, error) in
            let errorDomain = "Error occurred when getting students information: "
            
            guard error == nil else {
                print(errorDomain + error!.localizedDescription)
                performUIUpdatesOnMain {
                    self.setViewWaiting(false)
                    presentAlertControllerWithTitle("Fetching Data Failed", message: "Error occurred when getting students information.", FromHostViewController: self)
                }
                return
            }
            
            guard let studentsInfo = studentsInfo else {
                print(errorDomain + "No students information returned.")
                return
            }
            
            OTMClient.sharedInstance().studentsInfo = studentsInfo
            performUIUpdatesOnMain {
                self.setViewWaiting(false)
                self.tableView.reloadData()
            }
            
        }
    }
    
    func setViewWaiting(indicator: Bool) {
        UIView.animateWithDuration(0.25, animations: {
            self.view.backgroundColor = indicator ? UIColor.blackColor() : UIColor.whiteColor()
            self.tableView.alpha = indicator ? 0.6 : 1.0
            self.refreshButton.enabled = !indicator
        })
        indicator ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
}
