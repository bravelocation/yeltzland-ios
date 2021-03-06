//
//  WidgetTimelineProvider.swift
//  YeltzlandWidgetExtension
//
//  Created by John Pollard on 09/09/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import WidgetKit
import SwiftUI

struct WidgetTimelineProvider: TimelineProvider {
 
    func placeholder(in context: Context) -> WidgetTimelineData {
        return WidgetTimelineData(
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
            )
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetTimelineData) -> Void) {
        // Go and get the data in the background to prime the first showing of the widget
        GameScoreManager.shared.fetchLatestData(completion: nil)
        FixtureManager.shared.fetchLatestData(completion: nil)
        
        let entry = WidgetTimelineData(
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
                                     status: .fixture))
        
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetTimelineData>) -> Void) {
        // Go and get fresh data before updating the timeline
        print("Updating timeline ...")
        FixtureManager.shared.fetchLatestData() { _ in
            GameScoreManager.shared.fetchLatestData() { _ in
                var entries: [WidgetTimelineData] = []
                
                // Find the timeline entries for the widget
                let timelineManager = TimelineManager(fixtureManager: FixtureManager.shared, gameScoreManager: GameScoreManager.shared)
                let timelineEntries = timelineManager.timelineEntries
                
                var first: TimelineFixture?
                var second: TimelineFixture?
                
                if timelineEntries.count > 0 {
                    first = timelineEntries[0]
                }
                
                if timelineEntries.count > 1 {
                    second = timelineEntries[1]
                }
                
                // Set the date of the timeline entry and expiry time based on the first match
                 var expiryTime = Date().addingTimeInterval(60*60) // By default, update the widget every hour for fixture updates
                
                if let firstMatch = first {
                    if firstMatch.status == .inProgress {
                        expiryTime = Date().addingTimeInterval(60*5) // If in progress match, update every 5 minutes even if we get no in-game notifications
                        print("Match in progress - widget expiry time \(expiryTime)")
                    }
                }
                
                // Expiry time should never be after next game kickoff
                if let secondMatch = second {
                    if secondMatch.status == .fixture {
                        if expiryTime > secondMatch.date {
                            expiryTime = secondMatch.date
                            print("Expiry time is 2nd match kickoff - widget expiry time \(expiryTime)")
                        }
                    }
                }

                // Add the timeline entry
                let data = WidgetTimelineData(
                    date: Date(),
                    first: first,
                    second: second
                )
                
                entries.append(data)
                let timeline = Timeline(entries: entries, policy: .after(expiryTime))
                completion(timeline)
            }
        }
    }
    
    private func buildPlaceholder(
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
