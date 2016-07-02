//
//  OTMStudentInformation.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/2.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

// MARK: - OTMStudentInformation
struct OTMStudentInformation {
    
    // MARK: Properties
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectID: String
    let uniqueKey: String
    let updatedAt: String
    
    // MARK: Initializers
    init(dictionary: [String: AnyObject]) {
        createdAt = dictionary[OTMClient.ResponseKeys.CreatedAt] as! String
        firstName = dictionary[OTMClient.ResponseKeys.FirstName] as! String
        lastName = dictionary[OTMClient.ResponseKeys.LastName] as! String
        latitude = dictionary[OTMClient.ResponseKeys.Latitude] as! Double
        longitude = dictionary[OTMClient.ResponseKeys.Longitude] as! Double
        mapString = dictionary[OTMClient.ResponseKeys.MapString] as! String
        mediaURL = dictionary[OTMClient.ResponseKeys.MediaURL] as! String
        objectID = dictionary[OTMClient.ResponseKeys.ObjectId] as! String
        uniqueKey = dictionary[OTMClient.ResponseKeys.UniqueKey] as! String
        updatedAt = dictionary[OTMClient.ResponseKeys.UpdatedAt] as! String
    }
    
    static func studentsInformationFromResults(results: [[String: AnyObject]]) -> [OTMStudentInformation] {
        
        var studentsInformation = [OTMStudentInformation]()
        
        for result in results {
            studentsInformation.append(OTMStudentInformation(dictionary: result))
        }
        return studentsInformation
    }
    
}
