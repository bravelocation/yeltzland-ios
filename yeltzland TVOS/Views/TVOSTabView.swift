//
//  MainTabView.swift
//  Yeltzland
//
//  Created by John Pollard on 06/12/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

struct TVOSTabView: View {
    @EnvironmentObject var timelineData: TimelineData
    @EnvironmentObject var tweetData: TweetData
    @EnvironmentObject var fixtureData: FixtureData
    
    @State private var selection = 0
     
        var body: some View {
            TabView(selection: $selection) {
                TVOSTimelineView()
                    .tabItem {
                        HStack {
                            Text("Latest")
                        }
                    }
                    .tag(0)
                
                TVOSTwitterView()
                    .tabItem {
                        HStack {
                            Image("TwitterLogo")
                            Text("@halesowentownfc")
                        }
                    }
                    .tag(1)
                
                TVOSFixtureListView(resultsOnly: false)
                    .tabItem {
                        HStack {
                            Text("Fixtures")
                        }
                    }
                    .tag(2)
                
                TVOSFixtureListView(resultsOnly: true)
                    .tabItem {
                        HStack {
                            Text("Results")
                        }
                    }
                    .tag(3)
            }
        }
}

struct TVOSTabView_Previews: PreviewProvider {
    static var previews: some View {
        TVOSTabView()
    }
}
