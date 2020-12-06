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

                TVOSTwitterView()
                    .tabItem {
                        HStack {
                            Image("TwitterLogo")
                            Text("@halesowentownfc")
                        }
                    }
                    .tag(0)
                
                TVOSFixturesView()
                    .tabItem {
                        HStack {
                            Image("Fixtures")
                            Text("Fixtures")
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
