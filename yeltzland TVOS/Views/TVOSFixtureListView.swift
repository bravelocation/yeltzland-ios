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
        ScrollViewReader { scrollReader in
            List {
                ForEach(self.fixtureData.months, id: \.self) { month in
                    Text(self.fixtureData.monthName(month))
                        .font(.headline)
                        .focusable(true)
                    
                    ForEach(self.fixtureData.fixturesForMonth(month), id: \.self) { fixture in
                        TVOSFixtureView(fixture: fixture).environmentObject(self.fixtureData)
                    }
                }
            }
            .onAppear {
                self.fixtureData.refreshData() {
                    scrollReader.scrollTo(self.currentMonthSection())
                }
            }
        }
    }
    
    func currentMonthSection() -> String {
        var firstMonth: String? = nil

        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        let currentMonth = formatter.string(from: now)
        
        for month in self.fixtureData.months {
            if (month == currentMonth) {
                return currentMonth
            }
            
            if firstMonth == nil {
                firstMonth = month
            }
        }
        
        // No match found, so just start at the top
        return firstMonth ?? ""
    }
}

struct TVOSFixtureListView_Previews: PreviewProvider {
    static var previews: some View {
        TVOSFixtureListView().environmentObject(FixtureData())
    }
}
