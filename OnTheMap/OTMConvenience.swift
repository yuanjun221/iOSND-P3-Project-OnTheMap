//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/6/30.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient {
    
    func loginWithCredential(username: String,
                                 password: String,
                completionHandlerForLogin: (success: Bool, errorString: String?) -> Void) {
        
        let method: String = Constants.Methods.Session
        let parameters: [String: String!] = [
            Constants.ParameterKeys.Username: username,
            Constants.ParameterKeys.Password: password]
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody) { (result, error) in
            
            if let error = error {
                print(error.description)
                completionHandlerForLogin(success: false, errorString: "Connection timed out.")
            } else {
                if let _ = result[Constants.ResponseKeys.StatusCode] as? Int, errorString = result[Constants.ResponseKeys.Error] as? String {
                    completionHandlerForLogin(success: false, errorString: errorString)
                    return
                }
                
                guard let sessionDictionary = result[Constants.ResponseKeys.Session] as? [String: AnyObject] else {
                    print("Parse key 'session' failed.")
                    completionHandlerForLogin(success: false, errorString: "Get user info failed.")
                    return
                }
                
                guard let id = sessionDictionary[Constants.ResponseKeys.ID] as? String else {
                    print("Parse key 'id' failed.")
                    completionHandlerForLogin(success: false, errorString: "Get user info failed.")
                    return
                }
                
                OTMClient.sharedInstance().sessionID = id
                completionHandlerForLogin(success: true, errorString: nil)
            }
            
        }
        
    }
    
}
