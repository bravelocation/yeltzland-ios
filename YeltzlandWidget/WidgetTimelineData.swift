//
//  WidgetTimelineData.swift
//  YeltzlandWidgetExtension
//
//  Created by John Pollard on 09/09/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import WidgetKit
import SwiftUI

struct WidgetTimelineData: TimelineEntry {
    let date: Date
    let first: TimelineFixture?
    let second: TimelineFixture?
    
    var relevance: TimelineEntryRelevance? {
        if let firstMatch = first {
            if firstMatch.status == .inProgress {
                return TimelineEntryRelevance(score: 10.0)
            }
            
            if firstMatch.isToday {
                return TimelineEntryRelevance(score: 5.0)
            }
        }
        
        return TimelineEntryRelevance(score: 1.0)
    }
}
