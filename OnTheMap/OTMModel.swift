//
//  OTMModel.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/15.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

class OTMModel: NSObject {
    
    // MARK: Properties
    var userUniqueKey: String?
    var FBAccessToken: String?
    var studentsInfo = [OTMStudentInformation]()
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> OTMModel {
        struct Singleton {
            static var sharedInstance = OTMModel()
        }
        return Singleton.sharedInstance
    }

}
