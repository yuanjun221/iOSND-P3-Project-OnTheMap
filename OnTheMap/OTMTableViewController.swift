//
//  OTMTableViewController.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/3.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

class OTMTableViewController: UIViewController {
    
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
        return OTMClient.sharedInstance().studentsInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let studentInfo = OTMClient.sharedInstance().studentsInfo[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell") as! OTMTableViewCell
        if let countryCode = studentInfo.countryCode {
            cell.flagView.image = UIImage(named: countryCode)
        }
        cell.nameLabel.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        cell.urlLabel.text = studentInfo.mediaURL
        cell.dateLabel.text = (studentInfo.updatedAt as NSString).substringToIndex(10)
        
        return cell
    }
}


extension OTMTableViewController {
    
    func getStudentsInformation() {
        
        performUIUpdatesOnMain {
            self.setViewWaiting(true)
        }
        
        OTMClient.sharedInstance().getStudentsInformation { (studentsInfo, error) in
            if let studentsInfo = studentsInfo {
                
                OTMClient.sharedInstance().studentsInfo = studentsInfo
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                    self.setViewWaiting(false)
                }
                
            } else {
                print(error)
                self.setViewWaiting(false)
                presentAlertControllerWithTitle("Fetching Data Failed.", message: nil, FromHostViewController: self)
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
