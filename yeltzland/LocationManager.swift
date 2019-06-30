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

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

public class LocationManager {
    fileprivate static let sharedInstance = LocationManager()
    fileprivate var locationList: [Location] = [Location]()
    
    class var instance: LocationManager {
        get {
            return sharedInstance
        }
    }
    
    public var locations: [Location] {
        return self.locationList
    }
    
    init() {
        if let filePath = Bundle.main.path(forResource: "locations", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                let locations = json["Locations"] as! [AnyObject]
                
                self.locationList.removeAll()
                
                for currentLocation in locations {
                    if let location = currentLocation as? [String: AnyObject] {
                        let currentParsedLocation = Location(fromJson: location)
                        
                        if (currentParsedLocation.latitude != 0.0 && currentParsedLocation.longitude != 0.0) {
                            self.locationList.append(currentParsedLocation)
                        }
                    }
                }
                print("Loaded locations from bundled file")
            } catch {
                print("Error loading locations from bundled file ...")
                print(error)
            }
        }
    }
    
    func mapRegion() -> MKCoordinateRegion {
        var smallestLat = 190.0
        var largestLat = -190.0
        var smallestLong = 190.0
        var largestLong = -190.0
        
        for location in self.locations {
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
        let distance = topLeft.distance(from: bottomRight)
        
        // Now center map on Halesowen
        return MKCoordinateRegionMakeWithDistance(centerPoint.coordinate, distance, distance)
    }
}
