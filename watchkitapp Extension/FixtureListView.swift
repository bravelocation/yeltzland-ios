//
//  FixtureListView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import SwiftUI

struct FixtureListView: View {
    @ObservedObject var fixtureData = FixtureListData()
    var showResults: Bool
    
    let logoDim = CGFloat(40)
        
    var body: some View {
        VStack {
            Text(self.showResults ? "Results" : "Fixtures")
                .font(.headline)
                .foregroundColor(Color("light-blue"))
            
            List(self.showResults ? self.fixtureData.results : self.fixtureData.fixtures, id: \.self) { fixture in

                VStack(alignment: .leading) {
                    self.fixtureData.teamImage(fixture.opponentNoCup)
                        .resizable()
                        .scaledToFit()
                        .frame(width: self.logoDim, height: self.logoDim, alignment: .center)

                    Text(fixture.displayOpponent)
                            .lineLimit(2)
                    Text(fixture.tvResultDisplayKickoffTime)
                    Text(fixture.score)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(self.fixtureData.resultColor(fixture))
                }
                .padding(8)
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
        }
    }
}

struct FixtureListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FixtureListView(showResults: false)
            FixtureListView(showResults: true)
        }
    }
}
