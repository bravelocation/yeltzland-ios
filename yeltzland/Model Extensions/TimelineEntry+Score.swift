//
//  TimelineEntry+Score.swift
//  yeltzland
//
//  Created by John Pollard on 23/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

extension TimelineEntry {
    var score: String {
        get {
            if let teamScore = self.teamScore, let opponentScore = self.opponentScore {
                if self.status == .inProgress {
                    return "\(teamScore)-\(opponentScore)*"
                }
                
                return "\(teamScore)-\(opponentScore)"
            }
        
            return ""
        }
    }
}
