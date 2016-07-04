//
//  OTMHelper.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/3.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

func presentAlertControllerWithTitle(title: String?, message: String?, FromHostViewController hostViewController: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(okAction)
    hostViewController.presentViewController(alertController, animated: true, completion: nil)
}


