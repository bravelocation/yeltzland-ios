//
//  TVOSTimelineView.swift
//  YeltzlandTVOS
//
//  Created by John Pollard on 06/12/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

struct TVOSTimelineView: View {
    @EnvironmentObject var data: TimelineData
    
    var body: some View {
        VStack {
            HStack {
                Group {
                    if data.fixtures.count > 0 {
                        TVOSTimelineFixtureView(fixture: data.fixtures[0])
                    } else {
                        Text("No data available")
                    }
                }

                if data.fixtures.count > 1 {
                    Divider().background(Color("light-blue"))
                    TVOSTimelineFixtureView(fixture: data.fixtures[1])
                }
            }
        }
        .padding()
        .foregroundColor(Color("light-blue"))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color("light-blue"), lineWidth: 1)
        )
        .onAppear() {
            data.refreshData()
        }
    }
}

struct TVOSTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TVOSTimelineView().environmentObject(TimelineData())
    }
}
