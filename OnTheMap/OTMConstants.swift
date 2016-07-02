//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/6/30.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

extension OTMClient {
    
    struct Constants {
        static let ApiScheme = "https"
        
        static let UdacityApiHost = "www.udacity.com"
        static let UdacityApiPath = "/api"
        
        static let ParseApiHost = "api.parse.com"
        static let ParseApiPath = "/1"
    }
    
    struct Methods {
        // MARK: Udacity Methods
        static let Session = "/session"
        
        // MARK: Parse Methods
        static let StudentLocation = "/classes/StudentLocation"
    }
    
    struct ParameterKeys {
        // MARK: Udacity Parameter Keys
        static let Username = "username"
        static let Password = "password"
        
        // MARK: Parse Parameter Keys
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    struct ResponseKeys {
        static let Account = "account"
        static let Session = "session"
        static let ID = "id"
        static let StatusCode = "status"
        static let Error = "error"
        
        // MARK: Parse Student Information
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
        static let StudentResults = "results"
    }
}

extension OTMClient {
    
    enum HostIdentifier {
        case Udacity
        case Parse
    }
}
