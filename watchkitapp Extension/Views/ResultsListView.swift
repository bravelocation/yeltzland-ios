//
//  ResultsListView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import SwiftUI

struct ResultsListView: View {
    @ObservedObject var fixtureData: FixtureListData
    
    var body: some View {
        VStack {
            Text(self.fixtureData.results.count == 0 ? "No results" : "")
            
            List(self.fixtureData.results, id: \.self) { fixture in
                HStack {
                    ResultView(fixture: fixture,
                               teamImage: self.fixtureData.teamImage(fixture.opponentNoCup),
                               resultColor: self.fixtureData.resultColor(fixture))
                    
                    Spacer()
                }
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
        }
        .onAppear {
            self.fixtureData.refreshData()
        }
        .navigationBarTitle(Text("Results"))
    }
}

struct ResultsListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ResultsListView(
                fixtureData: FixtureListData(fixtureManager: PreviewFixtureManager(), gameScoreManager: PreviewGameScoreManager())
            )
        }
    }
}
