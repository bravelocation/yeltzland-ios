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
    
    var opponentAbbreviation: String {
        get {
            return self.truncateTeamName(self.opponent, max: 3)
        }
    }
    
    public var opponentShortened: String {
        get {
            return self.truncateTeamName(self.opponent, max: 16)
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
    
    private func truncateTeamName(_ original: String, max: Int) -> String {
        let originalLength = original.count
        
        // If the original is short enough, we're done
        if (originalLength <= max) {
            return original
        }
        
        // Find the first space
        var firstSpace = 0
        for c in original {
            if (c == Character(" ")) {
                break
            }
            firstSpace += 1
        }
        
        if (firstSpace < max) {
            return String(original[original.startIndex..<original.index(original.startIndex, offsetBy: firstSpace)])
        }
        
        // If still not found, just truncate it
        return original[original.startIndex..<original.index(original.startIndex, offsetBy: max)].trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
    }
}
