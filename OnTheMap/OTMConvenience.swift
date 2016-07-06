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
    
    func loginWithCredential(username: String, password: String, completionHandlerForLogin: (success: Bool, error: NSError?, errorMessage: String?) -> Void) {
        let method: String = Methods.Session
        let parameters: [String: AnyObject] = [
            ParameterKeys.Username: username,
            ParameterKeys.Password: password]
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody, host: .Udacity) { (results, error) in
            
            guard error == nil else {
                completionHandlerForLogin(success: false, error: error, errorMessage: "Connection timed out.")
                return
            }
            
            if let _ = results[ResponseKeys.StatusCode] as? Int, errorString = results[ResponseKeys.Error] as? String {
                completionHandlerForLogin(success: false, error: NSError(domain: "loginWithCredential", code: 0, userInfo: [NSLocalizedDescriptionKey: errorString]), errorMessage: errorString)
                return
            }
            
            guard let accountDictionary = results[ResponseKeys.Account] as? [String: AnyObject] else {
                completionHandlerForLogin(success: false, error: NSError(domain: "loginWithCredential", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.Account)' in \(results)"]), errorMessage: "Parse data from server failed.")
                return
            }
            
            guard let key = accountDictionary[ResponseKeys.Key] as? String else {
                completionHandlerForLogin(success: false, error: NSError(domain: "loginWithCredential", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.Key)' in \(accountDictionary)"]), errorMessage: "Parse data from server failed." )
                return
            }
            
            OTMClient.sharedInstance().userAccountKey = key
            completionHandlerForLogin(success: true, error: nil, errorMessage: nil)
        }
    }
    
    func getStudentsInformation(completionHandlerForStudentsInformation: (result: [OTMStudentInformation]?, error: NSError?) -> Void) {
        let method = Methods.StudentLocation
        let parameters: [String: AnyObject] = [
            ParameterKeys.Limit: ParameterValues.Limit,
            ParameterKeys.Order: "-" + ResponseKeys.UpdatedAt + "," + "-" + ResponseKeys.CreatedAt]
        
        taskForGETMethod(method, parameters: parameters, host: .Parse) { (results, error) in
            guard error == nil else {
                completionHandlerForStudentsInformation(result: nil, error: error)
                return
            }
            
            guard let studentResults = results[ResponseKeys.StudentResults] as? [[String: AnyObject]] else {
                completionHandlerForStudentsInformation(result: nil, error: NSError(domain: "getStudentsInformation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.StudentResults)' in \(results)"]))
                return
            }
            
            let studentsInfo = OTMStudentInformation.studentsInformationFromResults(studentResults)
            completionHandlerForStudentsInformation(result: studentsInfo, error: nil)
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
        
        guard -90 ... 90 ~= studentInfo.latitude && -180 ... 180 ~= studentInfo.longitude else {
            completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Parameters out of range: (lat: -90 to 90, log: -180 to 180) in \(studentInfo)"]))
            return
        }
        
        taskForGETMethod(method, parameters: parameters, host: .Google) { (results, error) in
            guard error == nil else {
                completionHandlerForCountryCode(result: nil, error: error)
                return
            }
            
            guard let stauts = results[ResponseKeys.StatusCode] as? String else {
                completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.StatusCode)' in \(results)"]))
                return
            }
            
            guard stauts == "OK" else {
                guard let errorMessage = results[ResponseKeys.ErrorMessage] as? String else {
                    completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server returned an error but could not find key '\(ResponseKeys.ErrorMessage)' in \(results)"]))
                    return
                }
                completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server returned an error: \(errorMessage)"]))
                return
            }
            
            guard let geoCodeResults = results[ResponseKeys.GeoCodeResults] as? [[String: AnyObject]] else {
                completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.GeoCodeResults)' in \(results)"]))
                return
            }
            
            let targetGeoCodeResult = geoCodeResults[0]
            
            guard let addressComponents = targetGeoCodeResult[ResponseKeys.AddressComponents] as? [[String: AnyObject]] else {
                completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.AddressComponents)' in \(targetGeoCodeResult)"]))
                return
            }
            
            let targetAddressComponent = addressComponents[0]
            
            guard let shortName = targetAddressComponent[ResponseKeys.ShortName] as? String else {
                completionHandlerForCountryCode(result: nil, error: NSError(domain: "getCountryCode parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.ShortName)' in \(targetAddressComponent)"]))
                return
            }
            
            completionHandlerForCountryCode(result: shortName, error: nil)
        }
    }
    
    func getUserImageUrlFromStudentInfo(studentInfo: OTMStudentInformation, completionHandlerForImageUrl: (result: NSURL?, error: NSError?) -> Void) {
        var mutableMethod: String = Methods.UserId
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: OTMClient.URLKeys.UserId, value: studentInfo.uniqueKey)!
        let parameters: [String: AnyObject] = [:]
        
        taskForGETMethod(mutableMethod, parameters: parameters, host: .Udacity) { (results, error) in
            guard error == nil else {
                completionHandlerForImageUrl(result: nil, error: error)
                return
            }
            
            guard let user = results[ResponseKeys.User] as? [String: AnyObject] else {
                completionHandlerForImageUrl(result: nil, error: NSError(domain: "getUserImage parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key 'ResponseKeys.User' in \(results)"]))
                return
            }
            
            guard let imageUrlString = user[ResponseKeys.ImageUrl] as? String else {
                completionHandlerForImageUrl(result: nil, error: NSError(domain: "getUserImage parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.ImageUrl)' in \(user)"]))
                return
            }
            
            let urlExtension = (imageUrlString as NSString).substringFromIndex(14)
            let parameters: [String: AnyObject] = [ParameterKeys.Size: ParameterValues.Size100]
            let imageUrl = self.otmURLFromParameters(parameters, withHost: .Robohash, pathExtension: urlExtension)
            
            completionHandlerForImageUrl(result: imageUrl, error: nil)
        }
    }
    
}
