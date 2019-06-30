//
//  LocationAnnotation.swift
//  yeltzland
//
//  Created by John Pollard on 06/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import MapKit

class LocationAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, team: String) {
        self.coordinate = coordinate
        self.title = team
        
        // Find away games
        var description = ""

        for awayGame in FixtureManager.instance.getAwayGames(team) {
            if (description != "") {
                description += ", "
            }
            
            if (awayGame.teamScore == nil || awayGame.opponentScore == nil) {
                description += awayGame.fullKickoffTime
            } else {
                description += awayGame.score
            }
        }
        
        self.subtitle = description
    }
}
