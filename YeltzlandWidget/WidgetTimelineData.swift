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
        return TimelineEntryRelevance(score: 1.0) // TODO: Set a proper relevance
    }
}
