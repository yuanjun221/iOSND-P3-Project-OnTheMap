//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/6/30.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension OTMClient {
    
    func loginWithCredential(username: String, password: String, completionHandlerForLogin: (success: Bool, error: NSError?, errorMessage: String?) -> Void) {
        let method: String = Methods.Session
        let parameters: [String: AnyObject] = [:]
        let jsonBody = "{\"\(JsonBodyKeys.Udacity)\": {\"\(JsonBodyKeys.Username)\": \"\(username)\", \"\(JsonBodyKeys.Password)\": \"\(password)\"}}"

        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody, host: .Udacity) { (results, error) in
            
            guard error == nil else {
                completionHandlerForLogin(success: false, error: error, errorMessage: "Connection timed out.")
                return
            }
            
            let errorDomain = "loginWithCredential"
            
            if let _ = results[ResponseKeys.StatusCode] as? Int, errorString = results[ResponseKeys.Error] as? String {
                completionHandlerForLogin(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: errorString]), errorMessage: errorString)
                return
            }
            
            guard let accountDictionary = results[ResponseKeys.Account] as? [String: AnyObject] else {
                completionHandlerForLogin(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.Account)' in \(results)"]), errorMessage: "Parse data from server failed.")
                return
            }
            
            guard let key = accountDictionary[ResponseKeys.Key] as? String else {
                completionHandlerForLogin(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.Key)' in \(accountDictionary)"]), errorMessage: "Parse data from server failed.")
                return
            }
            
            OTMClient.sharedInstance().userUniqueKey = key
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
            
            let errorDomain = "getStudentsInformation parsing"
            
            guard let studentResults = results[ResponseKeys.StudentResults] as? [[String: AnyObject]] else {
                completionHandlerForStudentsInformation(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.StudentResults)' in \(results)"]))
                return
            }
            
            let studentsInfo = OTMStudentInformation.studentsInformationFromResults(studentResults)
            completionHandlerForStudentsInformation(result: studentsInfo, error: nil)
        }
    }
    
    func getCountryCodeWithStudentInfo(studentInfo: OTMStudentInformation, completionHandlerForCountryCode: (result: String?, error: NSError?) -> Void) {
        
        let method = Methods.GeoCode
        let parameters: [String: AnyObject] = [
            ParameterKeys.Key: ParameterValues.Key,
            ParameterKeys.Latlng: "\(studentInfo.latitude),\(studentInfo.longitude)",
            ParameterKeys.ResultType: ParameterValues.Country,
            ParameterKeys.Language: ParameterValues.English
        ]
        
        let errorDomain = "getCountryCode parsing"
        
        guard -90 ... 90 ~= studentInfo.latitude && -180 ... 180 ~= studentInfo.longitude else {
            completionHandlerForCountryCode(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Parameters out of range: (lat: -90 to 90, log: -180 to 180) in \(studentInfo)"]))
            return
        }
        
        taskForGETMethod(method, parameters: parameters, host: .Google) { (results, error) in
            guard error == nil else {
                completionHandlerForCountryCode(result: nil, error: error)
                return
            }
            
            guard let stauts = results[ResponseKeys.StatusCode] as? String else {
                completionHandlerForCountryCode(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.StatusCode)' in \(results)"]))
                return
            }
            
            guard stauts == "OK" else {
                guard let errorMessage = results[ResponseKeys.ErrorMessage] as? String else {
                    completionHandlerForCountryCode(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Server returned an error but could not find key '\(ResponseKeys.ErrorMessage)' in \(results)"]))
                    return
                }
                completionHandlerForCountryCode(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Server returned an error: \(errorMessage)"]))
                return
            }
            
            guard let geoCodeResults = results[ResponseKeys.GeoCodeResults] as? [[String: AnyObject]] else {
                completionHandlerForCountryCode(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.GeoCodeResults)' in \(results)"]))
                return
            }
            
            let targetGeoCodeResult = geoCodeResults[0]
            
            guard let addressComponents = targetGeoCodeResult[ResponseKeys.AddressComponents] as? [[String: AnyObject]] else {
                completionHandlerForCountryCode(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.AddressComponents)' in \(targetGeoCodeResult)"]))
                return
            }
            
            let targetAddressComponent = addressComponents[0]
            
            guard let shortName = targetAddressComponent[ResponseKeys.ShortName] as? String else {
                completionHandlerForCountryCode(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.ShortName)' in \(targetAddressComponent)"]))
                return
            }
            
            completionHandlerForCountryCode(result: shortName, error: nil)
        }
    }
    
    func getUserImageUrlWithStudentInfo(studentInfo: OTMStudentInformation, completionHandlerForImageUrl: (result: NSURL?, error: NSError?) -> Void) {
        var mutableMethod: String = Methods.UserUniqueKey
        mutableMethod = subtituteKeyInString(mutableMethod, key: URLKeys.UniqueKey, withValue: studentInfo.uniqueKey)!
        let parameters: [String: AnyObject] = [:]
        
        taskForGETMethod(mutableMethod, parameters: parameters, host: .Udacity) { (results, error) in
            guard error == nil else {
                completionHandlerForImageUrl(result: nil, error: error)
                return
            }
            
            let errorDomain = "getUserImage parsing"
            
            guard let user = results[ResponseKeys.User] as? [String: AnyObject] else {
                completionHandlerForImageUrl(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.User)' in \(results)"]))
                return
            }
            
            guard let imageUrlString = user[ResponseKeys.ImageUrl] as? String else {
                completionHandlerForImageUrl(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.ImageUrl)' in \(user)"]))
                return
            }
            
            let urlExtension = (imageUrlString as NSString).substringFromIndex(14)
            let parameters: [String: AnyObject] = [ParameterKeys.Size: ParameterValues.Size100]
            let imageUrl = self.otmURLFromParameters(parameters, withHost: .Robohash, pathExtension: urlExtension)
            
            completionHandlerForImageUrl(result: imageUrl, error: nil)
        }
    }
    
    func getUserNameWithUniqueKey(uniqueKey: String, completionHandlerForUserName:(result:(String, String)?, error: NSError?) -> Void) {
        var mutableMethod: String = Methods.UserUniqueKey
        mutableMethod = subtituteKeyInString(mutableMethod, key: URLKeys.UniqueKey, withValue: uniqueKey)!
        let parameters = [String: AnyObject]()
        
        taskForGETMethod(mutableMethod, parameters: parameters, host: .Udacity) { (results, error) in
            guard error == nil else {
                completionHandlerForUserName(result: nil, error: error)
                return
            }
            
            let errorDomain = "getUserImage parsing"
            
            guard let user = results[ResponseKeys.User] as? [String: AnyObject] else {
                completionHandlerForUserName(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.User)' in \(results)"]))
                return
            }
            
            guard let firstName = user[ResponseKeys.UserFirstName] as? String else {
                completionHandlerForUserName(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.UserFirstName)' in \(user)"]))
                return
            }
            
            guard let lastName = user[ResponseKeys.UserLastName] as? String else {
                completionHandlerForUserName(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.UserLastName)' in \(user)"]))
                return
            }
            
            completionHandlerForUserName(result: (firstName, lastName), error: nil)
        }
    }
    
    func queryStudentInfoWithUniqueKey(key: String, completionHandlerForStudentInfo: (result: OTMStudentInformation?, error: NSError?) -> Void) {
        let method = Methods.StudentLocation
        let parameters: [String: AnyObject] = [
            ParameterKeys.Where: subtituteKeyInString(ParameterValues.UniqueKeyPair, key: URLKeys.UniqueKey, withValue: key)!]
        
        taskForGETMethod(method, parameters: parameters, host: .Parse) { (results, error) in
            guard error == nil else {
                completionHandlerForStudentInfo(result: nil, error: error)
                return
            }
            
            let errorDomain = "queryStudentInfo parsing"
            
            if let errorString = results[ResponseKeys.Error] as? String {
                completionHandlerForStudentInfo(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: errorString]))
                return
            }
            
            guard let studentResults = results[ResponseKeys.StudentResults] as? [[String: AnyObject]] else {
                completionHandlerForStudentInfo(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.StudentResults)' in \(results)"]))
                return
            }
            
            guard !studentResults.isEmpty else {
                completionHandlerForStudentInfo(result: nil, error: NSError(domain: errorDomain, code: -2000, userInfo: [NSLocalizedDescriptionKey: "No entry in '\(studentResults)"]))
                return
            }
            
            let studentInfo = OTMStudentInformation(dictionary: studentResults[0])
            completionHandlerForStudentInfo(result: studentInfo, error: nil)
        }
    }
    
    func postStudentLocation(WithUniqueKey uniqueKey: String, name: (String, String), mapString: String, mediaUrl: String, coordinate: CLLocationCoordinate2D, completionHandlerForPostStudentLocation: (success: Bool, error: NSError?) -> Void) {
        let method: String = Methods.StudentLocation
        let parameters: [String: AnyObject] = [:]
        let jsonBody = "{\"\(JsonBodyKeys.UniqueKey)\": \"\(uniqueKey)\", \"\(JsonBodyKeys.FirstName)\": \"\(name.0)\", \"\(JsonBodyKeys.LastName)\": \"\(name.1)\",\"\(JsonBodyKeys.MapString)\": \"\(mapString)\", \"\(JsonBodyKeys.MediaURL)\": \"\(mediaUrl)\",\"\(JsonBodyKeys.Latitude)\": \(coordinate.latitude), \"\(JsonBodyKeys.Longitude)\": \(coordinate.longitude)}"
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody, host: .Parse) { (results, error) in
            guard error == nil else {
                completionHandlerForPostStudentLocation(success: false, error: error)
                return
            }
            
            completionHandlerForPostStudentLocation(success: true, error: nil)
        }
    }
    
    func putStudentLocation(WithStudentInfo studentInfo: OTMStudentInformation, mapString: String, mediaUrl: String, coordinate: CLLocationCoordinate2D, completionHandlerForPutStudentLocation: (success: Bool, error: NSError?) -> Void) {
        var mutableMethod: String = Methods.StudentLocationObjectId
        mutableMethod = subtituteKeyInString(mutableMethod, key: URLKeys.ObjectId, withValue: studentInfo.objectID)!
        
        let parameters: [String: AnyObject] = [:]
        let jsonBody = "{\"\(JsonBodyKeys.UniqueKey)\": \"\(studentInfo.uniqueKey)\", \"\(JsonBodyKeys.FirstName)\": \"\(studentInfo.firstName)\", \"\(JsonBodyKeys.LastName)\": \"\(studentInfo.lastName)\",\"\(JsonBodyKeys.MapString)\": \"\(mapString)\", \"\(JsonBodyKeys.MediaURL)\": \"\(mediaUrl)\",\"\(JsonBodyKeys.Latitude)\": \(coordinate.latitude), \"\(JsonBodyKeys.Longitude)\": \(coordinate.longitude)}"
        
        taskForPUTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody, host: .Parse) { (results, error) in
            guard error == nil else {
                completionHandlerForPutStudentLocation(success: false, error: error)
                return
            }
            
            print(results)
            completionHandlerForPutStudentLocation(success: true, error: nil)
        }

    }
    
}
