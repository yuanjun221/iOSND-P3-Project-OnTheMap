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
    
    func loginWithCredential(username: String, password: String, completionHandlerForLogin: (success: Bool, errorString: String?) -> Void) {
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
        let parameters: [String: AnyObject] = [
            ParameterKeys.Limit: ParameterValues.Limit,
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
    
    func getCountryCodeFromStudentInfo(studentInfo: OTMStudentInformation, completionHandlerForCountryCode: (result: String?, error: NSError?) -> Void) {
        
        let method = Methods.GeoCode
        let parameters: [String: AnyObject] = [
            ParameterKeys.Key: ParameterValues.Key,
            ParameterKeys.Latlng: "\(studentInfo.latitude),\(studentInfo.longitude)",
            ParameterKeys.ResultType: ParameterValues.Country,
            ParameterKeys.Language: ParameterValues.English
        ]
        
        if studentInfo.latitude < -90 || studentInfo.latitude > 90 || studentInfo.longitude < -180 || studentInfo.longitude > 180 {
            completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Parameters out of range (lat: -90 to 90, log: -180 to 180)"]))
        } else {
            taskForGETMethod(method, parameters: parameters, host: .Google) { (results, error) in
                if let error = error {
                    completionHandlerForCountryCode(result: nil, error: error)
                } else {
                    guard let stauts = results[ResponseKeys.StatusCode] as? String else {
                        completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getCountryCode"]))
                        return
                    }
                    
                    if stauts == "OK" {
                        guard let geoCodeResults = results[ResponseKeys.GeoCodeResults] as? [[String: AnyObject]] else {
                            completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse 'geoCodeResults' in \(results)"]))
                            return
                        }
                        
                        let targetGeoCodeResult = geoCodeResults[0]
                        
                        guard let addressComponents = targetGeoCodeResult[ResponseKeys.AddressComponents] as? [[String: AnyObject]] else {
                            completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse 'addressComponents' in \(targetGeoCodeResult)"]))
                            return
                        }
                        
                        let targetAddressComponent = addressComponents[0]
                        
                        guard let shortName = targetAddressComponent[ResponseKeys.ShortName] as? String else {
                            completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse 'shortName' in \(targetAddressComponent)"]))
                            return
                        }
                        
                        completionHandlerForCountryCode(result: shortName, error: nil)
                        
                    } else {
                        guard let errorMessage = results[ResponseKeys.ErrorMessage] as? String else {
                            completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server returned an error but could not parse 'errorMessage' in \(results)"]))
                            return
                        }
                        completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server returned an error: \(errorMessage)"]))
                    }
                }
            }
        }
    }
    
}
