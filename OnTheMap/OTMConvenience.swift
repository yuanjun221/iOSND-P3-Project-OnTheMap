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


// MARK: - Request Method Convenience
extension OTMClient {
    
    // MARK: Login With Udacity Credential
    func loginWithUdacityCredential(username username: String, password: String, completionHandlerForLogin: (success: Bool, error: NSError?, errorMessage: String?) -> Void) {
        let method: String = Methods.Session
        let parameters = [String: AnyObject]()
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
                completionHandlerForLogin(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.Account)' in \(results)"]), errorMessage: "Login failed.")
                return
            }
            
            guard let key = accountDictionary[ResponseKeys.Key] as? String else {
                completionHandlerForLogin(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.Key)' in \(accountDictionary)"]), errorMessage: "Login failed.")
                return
            }
            
            OTMModel.sharedInstance().userUniqueKey = key
            completionHandlerForLogin(success: true, error: nil, errorMessage: nil)
        }
    }
    
    // MARK: Logout of Udacity
    func logoutOfUdacity(completionHandlerForLogout: (success: Bool, error: NSError?) -> Void) {
        let method: String = Methods.Session
        let parameters = [String: AnyObject]()
        
        taskForDELETEMethod(method, parameters: parameters, host: .Udacity) { (results, error) in
            guard error == nil else {
                completionHandlerForLogout(success: false, error: error)
                return
            }
            
            completionHandlerForLogout(success: true, error: nil)
        }
    }
    
    // MARK: Login With Facebook Authentication
    func loginWithFacebookAuthentication(accessToken token: String, completionHandlerForLogin: (success: Bool, error: NSError?, errorMessage: String?) -> Void) {
        let method: String = Methods.Session
        let parameters = [String: AnyObject]()
        let jsonBody = "{\"\(JsonBodyKeys.FacebookMobile)\": {\"\(JsonBodyKeys.AccessToken)\": \"\(token)\"}}"
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody, host: .Udacity) { (results, error) in
            guard error == nil else {
                completionHandlerForLogin(success: false, error: error, errorMessage: "Connection timed out.")
                return
            }
            
            let errorDomain = "loginWithFacebookAuthentication"
            
            if let _ = results[ResponseKeys.StatusCode] as? Int, errorString = results[ResponseKeys.Error] as? String {
                completionHandlerForLogin(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: errorString]), errorMessage: errorString)
                return
            }
            
            guard let accountDictionary = results[ResponseKeys.Account] as? [String: AnyObject] else {
                completionHandlerForLogin(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.Account)' in \(results)"]), errorMessage: "Login failed.")
                return
            }
            
            guard let key = accountDictionary[ResponseKeys.Key] as? String else {
                completionHandlerForLogin(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find key '\(ResponseKeys.Key)' in \(accountDictionary)"]), errorMessage: "Login failed.")
                return
            }
            
            OTMModel.sharedInstance().userUniqueKey = key
            completionHandlerForLogin(success: true, error: nil, errorMessage: nil)
            
        }
    }
    
    // MARK: Get Students Information
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
    
    // MARK: Get Country Code
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
            completionHandlerForCountryCode(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Location coordinate: (\(studentInfo.latitude), \(studentInfo.longitude)) out of range: (-90 ~ +90, -180 ~ +180)."]))
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
            
            if stauts == ResponseValues.ZeroResults {
                completionHandlerForCountryCode(result: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "No corresponding country code returned from location coordinate: (\(studentInfo.latitude), \(studentInfo.longitude))."]))
                return
            }
            
            guard stauts == ResponseValues.OK else {
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
    
    // MARK: Get Avatar Image
    func getAvatarImageWithUniqueKey(uniqueKey: String, completionHandlerForAvatarImage: (image: UIImage?, error: NSError?) -> Void) {
        
        let urlExtension = "/udacity-\(uniqueKey)"
        let parameters: [String: AnyObject] = [ParameterKeys.Size: ParameterValues.Size150]
        let imageUrl = otmURLFromParameters(parameters, withHost: .Robohash, pathExtension: urlExtension)

        let errorDomain = "GetUserImage Parsing"
        
        OTMClient.sharedInstance().taskForGETImageData(imageUrl) { (data, error) in
            guard error == nil else {
                print(errorDomain + error!.localizedDescription)
                completionHandlerForAvatarImage(image: nil, error: error)
                return
            }
            
            let errorDomain = "GetImageData Parsing"
            
            guard let data = data else {
                completionHandlerForAvatarImage(image: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "No image data returned."]))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completionHandlerForAvatarImage(image: nil, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "No image from image data."]))
                return
            }
            
            completionHandlerForAvatarImage(image: image, error: nil)
        }
    }
    
    // MARK: Get User Name
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
    
    // MARK: Query Student Info
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
    
    // MARK: Delete User Info
    func deleteStudentInfoWithObjectId(objectId: String, completionHandlerForDeleteStudentInfo: (success: Bool, error: NSError?) -> Void) {
        var mutableMethod: String = Methods.StudentLocationObjectId
        mutableMethod = subtituteKeyInString(mutableMethod, key: URLKeys.ObjectId, withValue: objectId)!
        let parameters = [String: AnyObject]()
        
        taskForDELETEMethod(mutableMethod, parameters: parameters, host: .Parse) { (results, error) in
            guard error == nil else {
                completionHandlerForDeleteStudentInfo(success: false, error: error)
                return
            }
            
            completionHandlerForDeleteStudentInfo(success: true, error: nil)
        }
    }
    
    // MARK: Post Student Location
    func postStudentLocation(WithUniqueKey uniqueKey: String, name: (String, String), mapString: String, mediaUrl: String, coordinate: CLLocationCoordinate2D, completionHandlerForPostStudentLocation: (success: Bool, error: NSError?) -> Void) {
        let method: String = Methods.StudentLocation
        let parameters = [String: AnyObject]()
        let jsonBody = "{\"\(JsonBodyKeys.UniqueKey)\": \"\(uniqueKey)\", \"\(JsonBodyKeys.FirstName)\": \"\(name.0)\", \"\(JsonBodyKeys.LastName)\": \"\(name.1)\",\"\(JsonBodyKeys.MapString)\": \"\(mapString)\", \"\(JsonBodyKeys.MediaURL)\": \"\(mediaUrl)\",\"\(JsonBodyKeys.Latitude)\": \(coordinate.latitude), \"\(JsonBodyKeys.Longitude)\": \(coordinate.longitude)}"
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody, host: .Parse) { (results, error) in
            guard error == nil else {
                completionHandlerForPostStudentLocation(success: false, error: error)
                return
            }
            
            completionHandlerForPostStudentLocation(success: true, error: nil)
        }
    }
    
    // MARK: Put Student Location
    func putStudentLocation(WithStudentInfo studentInfo: OTMStudentInformation, mapString: String, mediaUrl: String, coordinate: CLLocationCoordinate2D, completionHandlerForPutStudentLocation: (success: Bool, error: NSError?) -> Void) {
        var mutableMethod: String = Methods.StudentLocationObjectId
        mutableMethod = subtituteKeyInString(mutableMethod, key: URLKeys.ObjectId, withValue: studentInfo.objectID)!
        
        let parameters = [String: AnyObject]()
        let jsonBody = "{\"\(JsonBodyKeys.UniqueKey)\": \"\(studentInfo.uniqueKey)\", \"\(JsonBodyKeys.FirstName)\": \"\(studentInfo.firstName)\", \"\(JsonBodyKeys.LastName)\": \"\(studentInfo.lastName)\",\"\(JsonBodyKeys.MapString)\": \"\(mapString)\", \"\(JsonBodyKeys.MediaURL)\": \"\(mediaUrl)\",\"\(JsonBodyKeys.Latitude)\": \(coordinate.latitude), \"\(JsonBodyKeys.Longitude)\": \(coordinate.longitude)}"
        
        taskForPUTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody, host: .Parse) { (results, error) in
            guard error == nil else {
                completionHandlerForPutStudentLocation(success: false, error: error)
                return
            }
            
            completionHandlerForPutStudentLocation(success: true, error: nil)
        }

    }
    
}
