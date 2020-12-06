//
//  MainTabView.swift
//  Yeltzland
//
//  Created by John Pollard on 06/12/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

struct TVOSTabView: View {
    @EnvironmentObject var tweetData: TweetData
    
    @State private var selection = 0
     
        var body: some View {
            TabView(selection: $selection){
                TVOSFixturesView()
                    .tabItem {
                        HStack {
                            Image(systemName: "chart.pie")
                            Text("Fixtures")
                        }
                    }
                    .tag(0)
                
                TVOSTwitterView()
                    .tabItem {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                            Text("Twitter")
                        }
                    }
                    .tag(1)
            }
        }
}

struct TVOSTabView_Previews: PreviewProvider {
    static var previews: some View {
        TVOSTabView()
    }
}
