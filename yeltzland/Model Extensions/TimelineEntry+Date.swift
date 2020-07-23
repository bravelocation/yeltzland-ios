//
//  TimelineEntry+Date.swift
//  yeltzland
//
//  Created by John Pollard on 23/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

extension TimelineEntry {
    var kickoffTime: String {
        get {
            // Is the game today?
            let now = Date()
            let currentDayNumber = FixtureManager.dayNumber(now)
            let fixtureDayNumber = FixtureManager.dayNumber(self.date)
            
            if (currentDayNumber == fixtureDayNumber) {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                
                return formatter.string(from: self.date)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE dd MMM HH:mm"
                
                return formatter.string(from: self.date)
            }
        }
    }
    
    var minimalKickoffTime: String {
        get {
           // Is the game today?
           let now = Date()
           let currentDayNumber = FixtureManager.dayNumber(now)
           let fixtureDayNumber = FixtureManager.dayNumber(self.date)
           
           if (currentDayNumber == fixtureDayNumber) {
               let formatter = DateFormatter()
               formatter.dateFormat = "HHmm"
               
               return formatter.string(from: self.date)
           } else {
               let formatter = DateFormatter()
               formatter.dateFormat = "EEE d"
               
               return formatter.string(from: self.date)
           }
        }
    }
}
