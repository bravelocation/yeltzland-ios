//
//  FixtureListView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import SwiftUI

struct FixturesListView: View {
    @ObservedObject var fixtureData: FixtureListData
        
    var body: some View {
        VStack {
            if self.fixtureData.fixtures.count == 0 {
                Text("No fixtures").padding()
            }
            
            List(self.fixtureData.fixtures, id: \.self) { fixture in

                HStack {
                    FixtureView(fixture: fixture, teamImage: self.fixtureData.teamImage(fixture.opponentNoCup))

                    Spacer()
                }
            }
            .listStyle(CarouselListStyle())
        }
        .overlay(
            Button(action: {
                self.fixtureData.refreshData()
            }, label: {
                Image(systemName: "arrow.clockwise")
                    .font(.footnote)
                    .padding()

            })
            .buttonStyle(PlainButtonStyle())
            .frame(width: 24.0, height: 24.0, alignment: .center), alignment: .trailing
        )
        .foregroundColor(Color("light-blue"))
        .onAppear {
            self.fixtureData.refreshData()
        }
        .navigationBarTitle(Text("Fixtures"))
    }
}

struct FixtureListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FixturesListView(
                fixtureData: FixtureListData(fixtureManager: PreviewFixtureManager(), gameScoreManager: PreviewGameScoreManager())
            )
        }
    }
}
