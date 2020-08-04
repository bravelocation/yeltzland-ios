//
//  ResultView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 21/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI

struct ResultView: View {
    var fixture: TimelineFixture
    var teamImage: Image
    var resultColor: Color
    
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
                Text(fixture.resultKickoffTime)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote)
                Text(fixture.score)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(resultColor)
                    .font(.largeTitle)
            }
            .foregroundColor(Color("light-blue"))
            .padding(8)
            
            Spacer()
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ResultView(fixture: TimelineFixture(opponent: "Stourbridge",
                                               home: true,
                                               date: PreviewFixtureManager.makeDate(daysToAdd: 2),
                                               teamScore: 3,
                                               opponentScore: 0,
                                               status: .result),
                        teamImage: Image("preview-team"),
                        resultColor: Color("watch-fixture-win")
            )
            
            ResultView(fixture: TimelineFixture(opponent: "Kidderminster Harriers (WSC 2)",
                                               home: false,
                                               date: PreviewFixtureManager.makeDate(daysToAdd: 0),
                                               teamScore: 1,
                                               opponentScore: 1,
                                               status: .inProgress),
                        teamImage: Image("preview-team"),
                        resultColor: Color("watch-fixture-draw")
            )
            
            ResultView(fixture: TimelineFixture(opponent: "Stourbridge",
                                               home: true,
                                               date: PreviewFixtureManager.makeDate(daysToAdd: -14),
                                               teamScore: 0,
                                               opponentScore: 1,
                                               status: .result),
                        teamImage: Image("preview-team"),
                        resultColor: Color("watch-fixture-lose")
            )
        }
    }
}
