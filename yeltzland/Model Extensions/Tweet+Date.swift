//
//  Tweet+Date.swift
//  yeltzland
//
//  Created by John Pollard on 25/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

extension DisplayTweet {
    var timeAgo: String {
        get {
            if (self.isToday) {
               let formatter = DateFormatter()
               formatter.dateFormat = "HH:mm"
               
               return "Today\n\(formatter.string(from: self.createdAt))"
           } else {
               let formatter = DateFormatter()
               formatter.dateFormat = "EEE\nHH:mm"
               
               return formatter.string(from: self.createdAt)
           }
        }
    }
    
    var isToday: Bool {
        // Is the game today?
        let now = Date()
        let currentDayNumber = DateHelper.dayNumber(now)
        let fixtureDayNumber = DateHelper.dayNumber(self.createdAt)
        
        return currentDayNumber == fixtureDayNumber
    }
}
