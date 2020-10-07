//
//  YeltzlandWidget.swift
//  YeltzlandWidget
//
//  Created by John Pollard on 09/09/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct YeltzlandWidget: Widget {
    let kind: String = "YeltzlandWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { data in
            WidgetView(data: data)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Yeltzland")
        .description("Halesowen Town scores, results and fixtures")
    }
}
