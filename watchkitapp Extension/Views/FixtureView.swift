//
//  FixtureView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 21/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI

struct FixtureView: View {
    var fixture: TimelineEntry
    var teamImage: Image
    
    let logoDim = CGFloat(40)
    
    var body: some View {

        HStack {
            VStack(alignment: .leading) {
                self.teamImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.logoDim, height: self.logoDim, alignment: .center)

                Text(fixture.opponentPlusHomeAway)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.body)
                
                Text(fixture.kickoffTime)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(self.fixture.kickoffTime.count > 6 ? .headline : .largeTitle) // Prefer title2 in WatchOS7
            }
            .foregroundColor(Color("light-blue"))
            .padding(8)
            
            Spacer()
        }
    }
}

struct FixtureView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            FixtureView(fixture: TimelineEntry(opponent: "Stourbridge",
                                               home: true,
                                               date: PreviewFixtureManager.makeDate(daysToAdd: 2),
                                               teamScore: nil,
                                               opponentScore: nil,
                                               status: .fixture),
                        teamImage: Image("preview-team"))
            
            FixtureView(fixture: TimelineEntry(opponent: "Maidenhead United (FAT 2)",
                                               home: true,
                                               date: PreviewFixtureManager.makeDate(daysToAdd: 0),
                                               teamScore: nil,
                                               opponentScore: nil,
                                               status: .fixture),
                        teamImage: Image("preview-team"))
        }
    }
}
