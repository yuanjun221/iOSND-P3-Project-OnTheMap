//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/6/30.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
    
    var studentsInfo = [OTMStudentInformation]()
    var session = NSURLSession.sharedSession()
    
    var sessionID: String? = nil
    
    override init() {
        super.init()
    }
    
    func taskForGETMethod(method: String, parameters: [String: AnyObject], host: HostIdentifier, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withHost: host, pathExtension: method))
        
        switch host {
        case .Parse:
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        default:
            break
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(errorMessage: String) {
                print(errorMessage)
                let error = NSError(domain: "taskForGETMethod", code: 1, userInfo:[NSLocalizedDescriptionKey : errorMessage])
                completionHandlerForGET(result: nil, error: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error with request: \(error!.description)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        return task
    }
    
    func taskForPOSTMethod(method: String, parameters: [String: AnyObject], jsonBody: String, host: HostIdentifier, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withHost: host, pathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(errorMessage: String) {
                print(errorMessage)
                let error = NSError(domain: "taskForPOSTMethod", code: 1, userInfo:[NSLocalizedDescriptionKey : errorMessage])
                completionHandlerForPOST(result: nil, error: error)
            }
            
            guard error == nil else {
                sendError("There was an error with request: \(error!.description)")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let targetData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            print(NSString(data: targetData, encoding: NSUTF8StringEncoding))
            
            self.convertDataWithCompletionHandler(targetData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        task.resume()
        return task
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]))
        }
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    private func otmURLFromParameters(parameters: [String: AnyObject], withHost: HostIdentifier, pathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        switch withHost {
        case .Udacity:
            components.host = Constants.UdacityApiHost
            components.path = Constants.UdacityApiPath + (pathExtension ?? "")
        case .Parse:
            components.host = Constants.ParseApiHost
            components.path = Constants.ParseApiPath + (pathExtension ?? "")
        case .Google:
            components.host = Constants.GoogleMapsApiHost
            components.path = Constants.GoogleMapsApiPath + (pathExtension ?? "")
        }
    
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.URL!
    }
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
