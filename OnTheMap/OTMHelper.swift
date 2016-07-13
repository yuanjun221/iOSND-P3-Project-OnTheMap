//
//  OTMHelper.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/3.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

func presentAlertController(WithTitle title: String?, message: String?, ForHostViewController hostViewController: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(okAction)
    hostViewController.presentViewController(alertController, animated: true, completion: nil)
}

func presentAlertControllerWhileLogoutForhostViewController(host: UIViewController, completionHandlerForConfirmAction: () -> Void) {
    let alertController = UIAlertController(title: "Confirm Logout", message: "Do you want to log out?", preferredStyle: .Alert)
    let logoutAction = UIAlertAction(title: "Logout", style: .Destructive) { logoutAction in
        completionHandlerForConfirmAction()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(logoutAction)
    alertController.addAction(cancelAction)
    host.presentViewController(alertController, animated: true, completion: nil)
}

func setTabBarItemsEnabled(indicator: Bool, ForTabBarController tabBarController: UITabBarController) {
    for item in tabBarController.tabBar.items! {
        item.enabled = !indicator
    }
}



