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
                            .font(self.kickoffSize())
                        Text(fixture.displayScore)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(self.fixtureData.resultColor(fixture))
                            .font(self.scoreSize())
                    }
                    .foregroundColor(Color("light-blue"))
                    .padding(8)
                    
                    Spacer()
                }.overlay(
                    RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("light-blue"), lineWidth: 2)
                )
                    .padding(.top)
                    .padding(.bottom)
            }
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
    
    func kickoffSize() -> Font {
        if self.showResults {
            return .footnote
        } else {
            return .headline
        }
    }
    
    func scoreSize() -> Font {
        if self.showResults == false {
            return .footnote
        } else {
            return .largeTitle
        }
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
