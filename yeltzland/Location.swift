//
//  Location.swift
//  yeltzland
//
//  Created by John Pollard on 06/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

open class Location {
    var team: String
    var latitude: Double?
    var longitude: Double?
    
    init(fromJson: [String:AnyObject]) {
        // Parse properties from JSON location properties
        self.team = fromJson["Team"] as! String
        
        if let parsedLatitude = fromJson["Latitude"] as? String {
            self.latitude = Double(parsedLatitude)
        }
        
        if let parsedLongitude = fromJson["Longitude"] as? String {
            self.longitude = Double(parsedLongitude)
        }
    }
    
    init(team: String, latitude: Double, longitude: Double) {
        self.team = team
        self.latitude = latitude
        self.longitude = longitude
    }
}
