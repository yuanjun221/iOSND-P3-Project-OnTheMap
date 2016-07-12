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
        tableView.delegate = self
        tableView.dataSource = self
        
        if studentsInfo.isEmpty {
            getStudentsInformation()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if studentsInfo.count != 0 {
            tableView.reloadData()
        }
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
            detailViewController.studentIndex = tableView.indexPathForSelectedRow?.row
            detailViewController.onDismiss = { sender in
                self.getStudentsInformation()
            }
        }

    }
    
}


extension OTMTableViewController {
    @IBAction func refresh(sender: AnyObject) {
        getStudentsInformation()
    }
    
    @IBAction func pinButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("pinOnMap", sender: sender)
    }
}


extension OTMTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("pushDetailView", sender: tableView)
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
        cell.avatarImageView.image = UIImage(named: "DefaultAvatar")
        cell.flagImageView.image = UIImage(named: "Unkown")
        
        if let avatarImage = studentInfo.avatarImage {
            cell.avatarImageView.image = avatarImage
        } else {
            getAvatarImageWithInfo(studentInfo, forCell: cell, atIndexPath: indexPath)
        }
        
        if let countryCode = studentInfo.countryCode {
            cell.flagImageView.image = UIImage(named: countryCode)
        } else {
            getCountryCodeWithInfo(studentInfo, forCell: cell, atIndexPath: indexPath)
        }
        
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
                    presentAlertController(WithTitle: "Fetching Data Failed", message: "Error occurred when getting students information.", ForHostViewController: self)
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
    
    func getAvatarImageWithInfo(studentInfo: OTMStudentInformation, forCell cell: OTMTableViewCell, atIndexPath indexPath: NSIndexPath) {
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
            
            OTMClient.sharedInstance().studentsInfo[indexPath.row].avatarImage = image
            
            performUIUpdatesOnMain {
                cell.avatarImageView.image = image
            }
            
        }
    }
    
    func getCountryCodeWithInfo(studentInfo: OTMStudentInformation, forCell cell: OTMTableViewCell, atIndexPath indexPath: NSIndexPath) {
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
 
            performUIUpdatesOnMain {
                cell.flagImageView.image = UIImage(named: countryCode)
            }
            
            OTMClient.sharedInstance().studentsInfo[indexPath.row].countryCode = countryCode
        }
    }
    
    func setViewWaiting(indicator: Bool) {
        UIView.animateWithDuration(0.25) {
            self.view.backgroundColor = indicator ? UIColor.blackColor() : UIColor.whiteColor()
            self.tableView.alpha = indicator ? 0.6 : 1.0
            self.refreshButton.enabled = !indicator
        }
        indicator ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
}
