//
//  TimelineFixtureView.swift
//  YeltzlandWidgetExtension
//
//  Created by John Pollard on 09/09/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

struct TimelineFixtureView: View {
    var fixture: TimelineFixture
    
    var body: some View {

        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                TimelineMatchTitle(status: fixture.status)
                
                Text(fixture.opponentPlusHomeAway)
                    .lineLimit(2)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if (fixture.status == .fixture) {
                    Text(fixture.kickoffTime)
                        .lineLimit(2)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.title2)
                } else {
                    Text(fixture.score)
                        .foregroundColor(self.resultColor())
                        .lineLimit(2)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.title)
                }
            }
            
            Spacer()
        }
        .foregroundColor(Color("light-blue"))
        .background(ContainerRelativeShape().fill(Color("yeltz-blue")))
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

struct TimelineMatchTitle: View {
    var status: TimelineFixtureStatus
    
    var body: some View {
        HStack {
            if (status == .fixture) {
                Text("FIXTURE").font(.caption)
            } else if (status == .result) {
                Text("RESULT").font(.caption)
            } else {
                Text("LATEST").font(.caption)
            }
            
            Spacer()
            Image("club-badge")
        }

    }
}

struct TimelineFixtureView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            TimelineFixtureView(fixture: TimelineFixture(opponent: "Kidderminster Harriers (WSC 2)",
                                               home: true,
                                               date: PreviewFixtureManager.makeDate(daysToAdd: 2),
                                               teamScore: nil,
                                               opponentScore: nil,
                                               status: .fixture)
            ).previewContext(WidgetPreviewContext(family: .systemSmall))
            
            TimelineFixtureView(fixture: TimelineFixture(opponent: "Kidderminster Harriers (WSC 2)",
                                               home: false,
                                               date: PreviewFixtureManager.makeDate(daysToAdd: 0),
                                               teamScore: 1,
                                               opponentScore: 1,
                                               status: .inProgress)
            ).previewContext(WidgetPreviewContext(family: .systemSmall))
            
            TimelineFixtureView(fixture: TimelineFixture(opponent: "Kidderminster Harriers (WSC 2)",
                                               home: true,
                                               date: PreviewFixtureManager.makeDate(daysToAdd: -14),
                                               teamScore: 0,
                                               opponentScore: 1,
                                               status: .result)
            ).previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
