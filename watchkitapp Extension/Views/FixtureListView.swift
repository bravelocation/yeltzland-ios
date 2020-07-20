//
//  FixtureListView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import SwiftUI

struct FixtureListView: View {
    @ObservedObject var fixtureData: FixtureListData
    var showResults: Bool
    
    let logoDim = CGFloat(40)
        
    var body: some View {
        VStack {
            Text(self.showResults ? (self.fixtureData.results.count == 0 ? "No results" : "") : (self.fixtureData.fixtures.count == 0 ? "No fixtures" : ""))
            
            List(self.showResults ? self.fixtureData.results : self.fixtureData.fixtures, id: \.self) { fixture in

                HStack {
                    VStack(alignment: .leading) {
                        self.fixtureData.teamImage(fixture.opponentNoCup)
                            .resizable()
                            .scaledToFit()
                            .frame(width: self.logoDim, height: self.logoDim, alignment: .center)

                        Text(fixture.displayOpponent)
                            .lineLimit(2)
                            .font(.body)
                        Text(fixture.fullDisplayKickoffTime)
                            .font(self.kickoffSize(fixture))
                        Text(fixture.displayScore)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(self.fixtureData.resultColor(fixture))
                            .font(self.scoreSize(fixture))
                    }
                    .foregroundColor(Color("light-blue"))
                    .padding(8)
                    
                    Spacer()
                }
                .padding()
            }
            .listRowBackground(Color("yeltz-blue"))
            .listStyle(CarouselListStyle())
            .contextMenu(menuItems: {
                Button(action: {
                    self.fixtureData.refreshData()
                }, label: {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                        Text("Refresh data")
                    }
                })
            })
        }.navigationBarTitle(Text(showResults ? "Results" : "Fixtures"))
    }
    
    func kickoffSize(_ entry: TimelineEntry?) -> Font {
        if let entry = entry {
            switch (entry.status) {
            case .result, .inProgress:
                return .footnote
            case .fixture:
                let kickoffTime = entry.fullDisplayKickoffTime
                return kickoffTime.count > 6 ? .headline : .largeTitle
            }
        }
        
        return .body
    }
    
    func scoreSize(_ entry: TimelineEntry?) -> Font {
        if let entry = entry {
            switch (entry.status) {
            case .result, .inProgress:
                return .largeTitle
            case .fixture:
                return .footnote
            }
        }
        
        return .body
    }
}

struct FixtureListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FixtureListView(
                fixtureData: FixtureListData(fixtureManager: PreviewFixtureManager(), gameScoreManager: PreviewGameScoreManager()),
                showResults: false
            )
            FixtureListView(
                fixtureData: FixtureListData(fixtureManager: PreviewFixtureManager(), gameScoreManager: PreviewGameScoreManager()),
                showResults: true
            )
        }
    }
}
