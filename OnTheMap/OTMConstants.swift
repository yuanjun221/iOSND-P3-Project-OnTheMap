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
        
        static let GoogleMapsApiHost = "maps.googleapis.com"
        static let GoogleMapsApiPath = "/maps/api"
        
        static let RobohashApiHost = "robohash.org"
    }
    
    struct Methods {
        // MARK: Udacity Methods
        static let Session = "/session"
        static let UserId = "/users/user_id"
        
        // MARK: Parse Methods
        static let StudentLocation = "/classes/StudentLocation"
        
        // MARK: Google Maps Methods
        static let GeoCode = "/geocode/json"
    }
    
    struct URLKeys {
        static let UserId = "user_id"
    }
    
    struct ParameterKeys {
        // MARK: Udacity Parameter Keys
        static let Username = "username"
        static let Password = "password"
        
        // MARK: Parse Parameter Keys
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        
        // MARK: Google Maps GeoCode Parameter Keys
        static let Latlng = "latlng"
        static let Key = "key"
        static let ResultType = "result_type"
        static let Language = "language"
        
        // MARK: Robohash Parameter Keys
        static let Size = "size"
    }
    
    struct ParameterValues {
        // MARK: Parse Parameter Values
        static var Limit = "10"
        
        // MARK: Google Maps GeoCode Parameter Values
        static let Key = "AIzaSyBNUI5NM4Nv8Ejqit5rZRwP48nWqCDipvg"
        static let Country = "country"
        static let English = "EN"
        
        // MARK: Robohash Parameter Values
        static let Size100 = "100x100"
        // static let Size150 = "150x150"
    }
    
    struct ResponseKeys {
        // MARK: Udacity Response Keys
        static let Account = "account"
        static let Session = "session"
        static let Key = "key"
        static let ID = "id"
        static let StatusCode = "status"
        static let Error = "error"
        
        static let User = "user"
        static let ImageUrl = "_image_url"
        
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
        
        // MARK: Google Maps Response Keys
        static let ErrorMessage = "error_message"
        static let GeoCodeStatus = "status"
        static let GeoCodeResults = "results"
        static let AddressComponents = "address_components"
        static let ShortName = "short_name"
    }
}

extension OTMClient {
    
    enum HostIdentifier {
        case Udacity
        case Parse
        case Google
        case Robohash
    }
}
