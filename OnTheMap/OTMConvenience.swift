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
        
        let method: String = Methods.Session
        let parameters: [String: AnyObject] = [
            ParameterKeys.Username: username,
            ParameterKeys.Password: password]
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody, host: .Udacity) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForLogin(success: false, errorString: "Connection timed out.")
            } else {
                if let _ = results[ResponseKeys.StatusCode] as? Int, errorString = results[ResponseKeys.Error] as? String {
                    completionHandlerForLogin(success: false, errorString: errorString)
                    return
                }
                
                guard let sessionDictionary = results[ResponseKeys.Session] as? [String: AnyObject] else {
                    print("Parse key 'session' failed.")
                    completionHandlerForLogin(success: false, errorString: "Get user info failed.")
                    return
                }
                
                guard let id = sessionDictionary[ResponseKeys.ID] as? String else {
                    print("Parse key 'id' failed.")
                    completionHandlerForLogin(success: false, errorString: "Get user info failed.")
                    return
                }
                
                OTMClient.sharedInstance().sessionID = id
                completionHandlerForLogin(success: true, errorString: nil)
            }
        }
    }
    
    func getStudentsInformation(completionHandlerForStudentsInformation: (result: [OTMStudentInformation]?, error: NSError?) -> Void) {
        let method = Methods.StudentLocation
        let parameters: [String: AnyObject] = [ParameterKeys.Limit: 100,
        ParameterKeys.Order: "-" + ResponseKeys.UpdatedAt + "," + "-" + ResponseKeys.CreatedAt]
        
        taskForGETMethod(method, parameters: parameters, host: .Parse) { (results, error) in
            
            if let error = error {
                completionHandlerForStudentsInformation(result: nil, error: error)
            } else {
                if let results = results[ResponseKeys.StudentResults] as? [[String: AnyObject]] {
                    let studentsInfo = OTMStudentInformation.studentsInformationFromResults(results)
                    completionHandlerForStudentsInformation(result: studentsInfo, error: nil)
                } else {
                    completionHandlerForStudentsInformation(result: nil, error: NSError(domain: "getStudentsInformation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentsInformation"]))
                }
            }
        }
    }
    
    
}
