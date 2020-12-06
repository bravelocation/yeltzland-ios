//
//  FixtureListView.swift
//  Yeltzland
//
//  Created by John Pollard on 06/12/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

struct TVOSFixtureListView: View {
    @EnvironmentObject var fixtureData: FixtureData
        
    var body: some View {
        List {
            ForEach(self.fixtureData.months, id: \.self) { month in
                Text(self.fixtureData.monthName(month))
                    .font(.headline)
                
                ForEach(self.fixtureData.fixturesForMonth(month), id: \.self) { fixture in
                    TVOSFixtureView(fixture: fixture).environmentObject(self.fixtureData)
                }
            }
        }
        .onAppear {
            self.fixtureData.refreshData()
        }
    }
}

struct TVOSFixtureListView_Previews: PreviewProvider {
    static var previews: some View {
        TVOSFixtureListView().environmentObject(FixtureData())
    }
}
