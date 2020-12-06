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

@available(iOS 13.0.0, *)
struct FixtureListView: View {
    @EnvironmentObject var fixtureData: FixtureData
        
    var body: some View {
        List {
            ForEach(self.fixtureData.months, id: \.self) { month in
                Text(self.fixtureData.monthName(month))
                    .font(.headline)
                
                ForEach(self.fixtureData.fixturesForMonth(month), id: \.self) { fixture in
                    FixtureView(fixture: fixture).environmentObject(self.fixtureData)
                }
            }
        }
        .onAppear {
            self.fixtureData.refreshData()
        }
    }
}

@available(iOS 13.0.0, *)
struct FixtureListView_Previews: PreviewProvider {
    static var previews: some View {
        FixtureListView().environmentObject(FixtureData())
    }
}
