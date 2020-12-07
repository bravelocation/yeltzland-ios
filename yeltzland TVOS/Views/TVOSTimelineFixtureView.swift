//
//  TVOSTimelineFixtureView.swift
//  YeltzlandTVOS
//
//  Created by John Pollard on 06/12/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

struct TVOSTimelineFixtureView: View {
    @EnvironmentObject var data: TimelineData
    
    var fixture: TimelineFixture
    
    var body: some View {

        HStack(alignment: .center) {
            Spacer()
            
            VStack(alignment: .center) {
                Spacer()
                TVOSTimelineMatchTitle(status: fixture.status)
                
                self.data.teamPic(self.fixture)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200, alignment: .center)
                
                Text(fixture.opponentPlusHomeAway)
                    .font(.title)
                
                if (fixture.status == .fixture) {
                    Text(fixture.kickoffTime)
                        .font(.title2)
                } else {
                    Text(fixture.score)
                        .foregroundColor(self.resultColor())
                        .font(.title)
                }
                Spacer()
            }
            
            Spacer()
        }
        .foregroundColor(Color("light-blue"))
    }
    
    func resultColor() -> Color {
        switch fixture.result {
        case .win:
            return Color("watch-fixture-win")
        case .lose:
            return Color("watch-fixture-lose")
        default:
            return Color("light-blue")
        }
    }
}

struct TVOSTimelineMatchTitle: View {
    var status: TimelineFixtureStatus
    
    var body: some View {
        HStack {
            if (status == .fixture) {
                Text("FIXTURE")
            } else if (status == .result) {
                Text("RESULT")
            } else {
                Text("LATEST")
            }
        }
    }
}

struct TVOSTimelineFixtureView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            TVOSTimelineFixtureView(fixture: TimelineFixture(opponent: "Kidderminster Harriers (WSC 2)",
                                               home: true,
                                               date: PreviewFixtureManager.makeDate(daysToAdd: 2),
                                               teamScore: nil,
                                               opponentScore: nil,
                                               status: .fixture)
            )
        }
    }
}
