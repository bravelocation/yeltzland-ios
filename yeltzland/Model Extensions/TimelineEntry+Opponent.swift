//
//  Timeline+Opponent.swift
//  yeltzland
//
//  Created by John Pollard on 23/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

extension TimelineEntry {
    
    var opponentPlusHomeAway: String {
        get {
            if (self.home) {
                return "\(self.opponent.uppercased()) (H)"
            } else {
                return "\(self.opponent) (A)"
            }
        }
    }
    
    var logoImageName: String {
        // Do we have a bracket in the name
        let bracketPos = self.opponent.firstIndex(of: "(")
        if bracketPos == nil {
            return self.opponent
        } else {
            let beforeBracket = self.opponent.split(separator: "(", maxSplits: 1, omittingEmptySubsequences: true)[0]
            return beforeBracket.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        }
    }
}
