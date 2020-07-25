//
//  Tweet+Date.swift
//  yeltzland
//
//  Created by John Pollard on 25/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

extension Tweet {
    var timeAgo: String {
        get {
           // Is the game today?
           let now = Date()
           let currentDayNumber = FixtureManager.dayNumber(now)
           let tweetDayNumber = FixtureManager.dayNumber(self.createdAt)
           
           if (currentDayNumber == tweetDayNumber) {
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
}
