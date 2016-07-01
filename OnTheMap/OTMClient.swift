//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/6/30.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
    
    var session = NSURLSession.sharedSession()
    
    var sessionID: String? = nil
    
    override init() {
        super.init()
    }
    
    
    func taskForPOSTMethod(method: String,
                       parameters: [String: AnyObject],
                         jsonBody: String,
         completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withPathExtension: method))
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
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            let error = NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo)
            completionHandlerForConvertData(result: nil, error: error)
        }
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    private func otmURLFromParameters(parameters: [String: AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = OTMClient.Constants.ApiScheme
        components.host = OTMClient.Constants.ApiHost
        components.path = OTMClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.URL!
    }
    
    /*
    func sendError(withDomian domian: String, code: NSInteger, message: String, completionHandler:(result: AnyObject!, error: NSError?) -> Void) {
        print(message)
        let error = NSError(domain: domian, code: code, userInfo:[NSLocalizedDescriptionKey : message])
        completionHandler(result: nil, error: error)
    }
    */
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
