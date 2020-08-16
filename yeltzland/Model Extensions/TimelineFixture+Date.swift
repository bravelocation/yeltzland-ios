//
//  TimelineFixture+Date.swift
//  yeltzland
//
//  Created by John Pollard on 23/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

extension TimelineFixture {
    var kickoffTime: String {
        get {
            // Is the game today?
            if (self.isToday) {
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
    
    var resultKickoffTime: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE dd MMM"
                
            return formatter.string(from: self.date)
        }
    }
    
    var minimalKickoffTime: String {
        get {
           // Is the game today?
           if (self.isToday) {
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
    
    var isToday: Bool {
        // Is the game today?
        let now = Date()
        let currentDayNumber = DateHelper.dayNumber(now)
        let fixtureDayNumber = DateHelper.dayNumber(self.date)
        
        return currentDayNumber == fixtureDayNumber
    }
    
    var daysSinceResult: Int {
        let dayNumberForResult = DateHelper.dayNumber(self.date)
        let dayNumberForToday = DateHelper.dayNumber(Date())
        
        return dayNumberForToday - dayNumberForResult
    }
}
