//
//  OTMWebViewController.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/12.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

class OTMWebViewController: UIViewController {
    
    var urlRequest: NSURLRequest!
    
    @IBOutlet weak var webView: UIWebView!
}


extension OTMWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = urlRequest.URL?.host
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let urlRequest = urlRequest {
            webView.loadRequest(urlRequest)
        }
    }
}


extension OTMWebViewController {
    
    @IBAction func actionButtonPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "Open With Safari?", message: nil, preferredStyle: .ActionSheet)
        let okAction = UIAlertAction(title: "OK", style: .Default) { okAction in
            UIApplication.sharedApplication().openURL(self.urlRequest.URL!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
