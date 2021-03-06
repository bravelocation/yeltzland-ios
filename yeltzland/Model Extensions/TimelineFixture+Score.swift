//
//  TimelineFixture+Score.swift
//  yeltzland
//
//  Created by John Pollard on 23/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

extension TimelineFixture {
    var score: String {
        get {
            if let teamScore = self.teamScore, let opponentScore = self.opponentScore {
                if self.status == .inProgress {
                    return "\(teamScore)-\(opponentScore)*"
                }
                
                return "\(teamScore)-\(opponentScore)"
            }
        
            if self.status == .inProgress {
                return "0-0*"
            }
            
            return ""
        }
    }
}
