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
    
    var userUniqueKey: String?
    var FBAccessToken: String?
    var studentsInfo = [OTMStudentInformation]()
    
    override init() {
        super.init()
    }
    
    func taskForGETMethod(method: String, parameters: [String: AnyObject], host: HostIdentifier, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withHost: host, pathExtension: method))
        
        switch host {
        case .Parse:
            request.addValue("\(HTTPHeaderValues.ParseApplicationID)", forHTTPHeaderField: "\(HTTPHeaderKeys.ParseApplicationID)")
            request.addValue("\(HTTPHeaderValues.ParseRESTApiKey)", forHTTPHeaderField: "\(HTTPHeaderKeys.ParseRESTApiKey)")
        default:
            break
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(errorMessage: String) {
                let error = NSError(domain: "taskForGETMethod", code: -2001, userInfo:[NSLocalizedDescriptionKey : errorMessage])
                completionHandlerForGET(result: nil, error: error)
            }
            
            guard error == nil else {
                sendError("There was an error with request: \(error!.localizedDescription)")
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
            
            var targetData = data
            
            switch host {
            case .Udacity:
                targetData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            default:
                break
            }
            
            self.convertDataWithCompletionHandler(targetData, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        return task
    }
    
    func taskForPOSTMethod(method: String, parameters: [String: AnyObject], jsonBody: String, host: HostIdentifier, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withHost: host, pathExtension: method))
        request.HTTPMethod = "POST"
        
        switch host {
        case .Udacity:
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        case .Parse:
            request.addValue("\(HTTPHeaderValues.ParseApplicationID)", forHTTPHeaderField: "\(HTTPHeaderKeys.ParseApplicationID)")
            request.addValue("\(HTTPHeaderValues.ParseRESTApiKey)", forHTTPHeaderField: "\(HTTPHeaderKeys.ParseRESTApiKey)")
        default:
            break
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(errorMessage: String) {
                let error = NSError(domain: "taskForPOSTMethod", code: 1, userInfo:[NSLocalizedDescriptionKey : errorMessage])
                completionHandlerForPOST(result: nil, error: error)
            }
            
            guard error == nil else {
                sendError("There was an error with request: \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            var targetData = data
            
            switch host {
            case .Udacity:
                targetData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            default:
                break
            }
            
            self.convertDataWithCompletionHandler(targetData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        task.resume()
        return task
    }
    
    func taskForPUTMethod(method: String, parameters: [String: AnyObject], jsonBody: String, host: HostIdentifier, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withHost: host, pathExtension: method))
        request.HTTPMethod = "PUT"
        request.addValue("\(HTTPHeaderValues.ParseApplicationID)", forHTTPHeaderField: "\(HTTPHeaderKeys.ParseApplicationID)")
        request.addValue("\(HTTPHeaderValues.ParseRESTApiKey)", forHTTPHeaderField: "\(HTTPHeaderKeys.ParseRESTApiKey)")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(errorMessage: String) {
                let error = NSError(domain: "taskForPUTMethod", code: 1, userInfo:[NSLocalizedDescriptionKey : errorMessage])
                completionHandlerForPOST(result: nil, error: error)
            }
            
            guard error == nil else {
                sendError("There was an error with request: \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        task.resume()
        return task
    }
    
    func taskForDELETEMethod(method: String, parameters: [String: AnyObject], host: HostIdentifier, completionHandlerForDELETE: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withHost: host, pathExtension: method))
        request.HTTPMethod = "DELETE"
        
        switch host {
        case .Udacity:
            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
        case .Parse:
            request.addValue("\(HTTPHeaderValues.ParseApplicationID)", forHTTPHeaderField: "\(HTTPHeaderKeys.ParseApplicationID)")
            request.addValue("\(HTTPHeaderValues.ParseRESTApiKey)", forHTTPHeaderField: "\(HTTPHeaderKeys.ParseRESTApiKey)")
        default:
            break
        }

        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(errorMessage: String) {
                let error = NSError(domain: "taskForDELETEMethod", code: 1, userInfo:[NSLocalizedDescriptionKey : errorMessage])
                completionHandlerForDELETE(result: nil, error: error)
            }
            
            guard error == nil else {
                sendError("There was an error with request: \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            var targetData = data
            
            switch host {
            case .Udacity:
                targetData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            default:
                break
            }
            
            self.convertDataWithCompletionHandler(targetData, completionHandlerForConvertData: completionHandlerForDELETE)
        }
        
        task.resume()
        return task
    }
    
    func taskForGETImageData(url: NSURL, completionHandlerForGETImageData: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(error: String) {
                completionHandlerForGETImageData(imageData: nil, error: NSError(domain: "taskForGETImageData", code: 1, userInfo: [NSLocalizedDescriptionKey : error]))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
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
            
            completionHandlerForGETImageData(imageData: data, error: nil)
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
    
    func otmURLFromParameters(parameters: [String: AnyObject], withHost: HostIdentifier, pathExtension: String? = nil) -> NSURL {
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
        case .Robohash:
            components.host = Constants.RobohashApiHost
            components.path = pathExtension ?? ""
        }
    
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.URL!
    }
    
    func subtituteKeyInString(string: String, key: String, withValue value: String) -> String? {
        if string.rangeOfString("\(key)") != nil {
            return string.stringByReplacingOccurrencesOfString("\(key)", withString: value)
        } else {
            return nil
        }
    }
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
