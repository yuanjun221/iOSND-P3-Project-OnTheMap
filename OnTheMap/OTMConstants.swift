//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/6/30.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

// MARK: - Constants
extension OTMClient {
    
    // MARK: - API Constants
    struct Constants {
        
        // MARK: URL Components
        static let ApiScheme = "https"
        
        static let UdacityApiHost = "www.udacity.com"
        static let UdacityApiPath = "/api"
        
        static let ParseApiHost = "api.parse.com"
        static let ParseApiPath = "/1"
        
        static let GoogleMapsApiHost = "maps.googleapis.com"
        static let GoogleMapsApiPath = "/maps/api"
        
        static let RobohashApiHost = "robohash.org"
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Udacity API Methods
        static let Session = "/session"
        static let UserUniqueKey = "/users/{key}"
        
        // MARK: Parse API Methods
        static let StudentLocation = "/classes/StudentLocation"
        static let StudentLocationObjectId = "/classes/StudentLocation/{objectId}"
        
        // MARK: Google Maps API Methods
        static let GeoCode = "/geocode/json"
    }
    
    // MARK: - Request Header Keys
    struct HTTPHeaderKeys {
        static let ParseApplicationID = "X-Parse-Application-Id"
        static let ParseRESTApiKey = "X-Parse-REST-API-Key"
    }
    
    // MARK: - Request Header Values
    struct HTTPHeaderValues {
        static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        static let UniqueKey = "{key}"
        static let ObjectId = "{objectId}"
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        // MARK: Udacity Parameter Keys
        static let Username = "username"
        static let Password = "password"
        
        // MARK: Parse Parameter Keys
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
        
        // MARK: Google Maps GeoCode Parameter Keys
        static let Latlng = "latlng"
        static let Key = "key"
        static let ResultType = "result_type"
        static let Language = "language"
        
        // MARK: Robohash Parameter Keys
        static let Size = "size"
    }
    
    // MARK: - Parameter Values
    struct ParameterValues {
        
        // MARK: Parse Parameter Values
        static var Limit = "100"
        static let UniqueKeyPair = "{\"uniqueKey\":\"{key}\"}"
        
        // MARK: Google Maps GeoCode Parameter Values
        static let Key = "AIzaSyBNUI5NM4Nv8Ejqit5rZRwP48nWqCDipvg"
        static let Country = "country"
        static let English = "EN"
        
        // MARK: Robohash Parameter Values
        static let Size100 = "100x100"
        static let Size150 = "150x150"
    }
    
    // MARK: - JSON Body Keys
    struct JsonBodyKeys {
        
        // MARK: Udacity
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        
        // MARK: Facebook
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
        
        // MARK: Parse
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    // MARK: - JSON Response Keys
    struct ResponseKeys {
        
        // MARK: Udacity Authorization
        static let Account = "account"
        static let Session = "session"
        static let Key = "key"
        static let ID = "id"
        static let StatusCode = "status"
        static let Error = "error"
        
        // MARK: Udacity Public User Info
        static let User = "user"
        static let UserFirstName = "first_name"
        static let UserLastName = "last_name"
        
        // MARK: Parse Student Info
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
        
        // MARK: Google Maps
        static let ErrorMessage = "error_message"
        static let GeoCodeStatus = "status"
        static let GeoCodeResults = "results"
        static let AddressComponents = "address_components"
        static let ShortName = "short_name"
    }
    
    // MARK: - URL Constants
    struct Urls {
        static let UdacitySignUpUrl = "https://www.udacity.com/account/auth#!/signup"
    }
    
    // MARK: - Segue Identifier
    struct SegueId {
        static let UdacityLogin = "UdacityLogin"
        static let FacebookLogin = "FacebookLogin"
        static let PushDetailView = "pushDetailView"
        static let PinOnMap = "pinOnMap"
        static let PushWebView = "pushWebView"
    }
    
    
    struct TableCellId {
        static let TableCell = "tableCell"
        static let NameCell = "nameCell"
        static let MapViewCell = "mapViewCell"
        static let UrlCell = "urlCell"
    }
}


// MARK: - Identifier
extension OTMClient {
    
    // MARK:- Host Indentifier
    enum HostIdentifier {
        case Udacity
        case Parse
        case Google
        case Robohash
    }
    
    // MARK: - Login Type
    enum LoginType {
        case Udacity
        case Facebook
    }
}
