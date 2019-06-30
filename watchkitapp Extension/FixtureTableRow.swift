//
//  FixtureTableRow.swift
//  yeltzland
//
//  Created by John Pollard on 30/09/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import WatchKit

class FixtureRowType: NSObject {
    @IBOutlet var labelDateTime: WKInterfaceLabel!
    @IBOutlet var labelhomeAway: WKInterfaceLabel!
    @IBOutlet var labelOpponent: WKInterfaceLabel!
    @IBOutlet var labelScore: WKInterfaceLabel!
    @IBOutlet var teamImage: WKInterfaceImage!
    
    public func loadFixture(_ fixture: Fixture, resultColor: UIColor) {
        
        self.labelDateTime?.setText(fixture.tvResultDisplayKickoffTime)
        self.labelOpponent?.setText(fixture.displayOpponent)
        self.labelhomeAway?.setText(fixture.home ? "at home to" : "away at")
        
        if (fixture.teamScore == nil && fixture.opponentScore == nil) {
            self.labelScore?.setText("")
        } else {
            self.labelScore?.setText(fixture.score)
        }
        
        TeamImageManager.instance.loadTeamImage(teamName: fixture.opponent, view: self.teamImage)

        self.labelScore?.setTextColor(resultColor)
    }
}
