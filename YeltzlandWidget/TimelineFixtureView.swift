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
                    .fixedSize(horizontal: false, vertical: true)
                    
                if (fixture.status == .fixture) {
                    Text(fixture.kickoffTime)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.headline)
                } else {
                    Text(fixture.score)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.title)
                }
                Spacer()
            }
            
            Spacer()
        }
        .foregroundColor(Color("light-blue"))
        .background(ContainerRelativeShape().fill(Color("yeltz-blue")))
    }
}

struct TimelineMatchTitle: View {
    var status: TimelineFixtureStatus
    
    var body: some View {
        if (status == .fixture) {
            Text("FIXTURE").font(.subheadline)
        } else if (status == .result) {
            Text("RESULT").font(.subheadline)
        } else {
            Text("LATEST SCORE").font(.subheadline)
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
