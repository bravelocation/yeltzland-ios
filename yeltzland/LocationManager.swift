//
//  LocationManager.swift
//  yeltzland
//
//  Created by John Pollard on 06/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public class LocationManager {
    private static let sharedInstance = LocationManager()
    private var locationList:[Location] = [Location]()
    
    class var instance:LocationManager {
        get {
            return sharedInstance
        }
    }
    
    public var Locations: [Location] {
        return self.locationList
    }
    
    init() {
        if let filePath = NSBundle.mainBundle().pathForResource("locations", ofType: "json"), data = NSData(contentsOfFile: filePath) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                let locations = json["Locations"] as! Array<AnyObject>
                
                self.locationList.removeAll()
                
                for currentLocation in locations {
                    if let location = currentLocation as? [String:AnyObject] {
                        let currentParsedLocation = Location(fromJson: location)
                        
                        if (currentParsedLocation.latitude != 0.0 && currentParsedLocation.longitude != 0.0) {
                            self.locationList.append(currentParsedLocation)
                        }
                    }
                }
                print("Loaded locations from cache")
            } catch {
                print("Error loading locations from cache ...")
                print(error)
            }
        }
    }
    
    func mapRegion() -> MKCoordinateRegion {
        var smallestLat = 190.0
        var largestLat = -190.0
        var smallestLong = 190.0
        var largestLong = -190.0
        
        for location in self.Locations {
            if (location.latitude < smallestLat) {
                smallestLat = location.latitude!
            }
            if (location.latitude > largestLat) {
                largestLat = location.latitude!
            }
            if (location.longitude < smallestLong) {
                smallestLong = location.longitude!
            }
            if (location.longitude > largestLong) {
                largestLong = location.longitude!
            }
        }
        
        // Set locations for edge points
        let topLeft = CLLocation(latitude: smallestLat, longitude: smallestLong)
        let bottomRight = CLLocation(latitude: largestLat, longitude: largestLong)
        let centerPoint = CLLocation(latitude: ((largestLat + smallestLat) / 2.0), longitude: ((largestLong + smallestLong) / 2.0))
        let distance = topLeft.distanceFromLocation(bottomRight)
        
        // Now center map on Halesowen
        return MKCoordinateRegionMakeWithDistance(centerPoint.coordinate, distance, distance)
    }
}
