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
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        
        struct Methods {
            static let Session = "/session"
        }
        
        struct ParameterKeys {
            static let Username = "username"
            static let Password = "password"
        }
        
        struct ResponseKeys {
            static let Account = "account"
            static let Session = "session"
            static let ID = "id"
            static let StatusCode = "status"
            static let Error = "error"
        }

        
    }
    
    
}
