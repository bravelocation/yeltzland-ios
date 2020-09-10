//
//  WidgetView.swift
//  YeltzlandWidgetExtension
//
//  Created by John Pollard on 09/09/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import WidgetKit
import SwiftUI

struct WidgetView: View {
    var data: WidgetTimelineData
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        HStack {
            Group {
                if data.first != nil {
                    TimelineFixtureView(fixture: data.first!)
                } else {
                    Text("No data available")
                }
            }

            if data.second != nil && widgetFamily == .systemMedium {
                Divider().background(Color("light-blue"))
                TimelineFixtureView(fixture: data.second!)
            }
            
            Spacer()
        }.padding()
        .foregroundColor(Color("light-blue"))
        .background(ContainerRelativeShape().fill(Color("yeltz-blue")))
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(data: WidgetTimelineData(
            date: Date(),
            first: buildPlaceholder(opponent: "Barnet (FAT QF)",
                                    home: false,
                                    date: "2020-02-29 15:00",
                                    teamScore: 2,
                                    opponentScore: 1,
                                    status: .result),
            second: buildPlaceholder(opponent: "Concord Rangers (FAT SF)",
                                     home: false,
                                     date: "2020-09-05 15:00",
                                     teamScore: nil,
                                     opponentScore: nil,
                                     status: .fixture)
        )).previewContext(WidgetPreviewContext(family: .systemSmall))
        
        WidgetView(data: WidgetTimelineData(
            date: Date(),
            first: buildPlaceholder(opponent: "Barnet (FAT QF)",
                                    home: false,
                                    date: "2020-02-29 15:00",
                                    teamScore: 2,
                                    opponentScore: 1,
                                    status: .result),
            second: buildPlaceholder(opponent: "Concord Rangers (FAT SF)",
                                     home: false,
                                     date: "2020-09-05 15:00",
                                     teamScore: nil,
                                     opponentScore: nil,
                                     status: .fixture)
        )).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
    
    private static func buildPlaceholder(
        opponent: String,
        home: Bool,
        date: String,
        teamScore: Int?,
        opponentScore: Int?,
        status: TimelineFixtureStatus) -> TimelineFixture {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return TimelineFixture(
            opponent: opponent,
            home: home,
            date: dateFormatter.date(from: date)!,
            teamScore: teamScore,
            opponentScore: opponentScore,
            status: status)
    }
}
