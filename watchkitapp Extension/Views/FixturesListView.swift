//
//  FixtureListView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import SwiftUI

struct FixturesListView: View {
    @ObservedObject var gamesData: AllGamesData
        
    var body: some View {
        VStack {
            if self.gamesData.games.count == 0 {
                Text("No fixtures").padding()
            }
            
            List(self.gamesData.games, id: \.self) { fixture in

                HStack {
                    FixtureView(fixture: fixture, teamImage: self.gamesData.teamImage(fixture.opponentNoCup))

                    Spacer()
                }
            }
            .listStyle(CarouselListStyle())
        }
        .overlay(
            Button(action: {
                self.gamesData.refreshData()
            }, label: {
                Image(systemName: "arrow.clockwise")
                    .font(.footnote)
                    .padding()

            })
            .frame(width: 24.0, height: 24.0, alignment: .center)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(12), alignment: .bottomTrailing
        )
        .foregroundColor(Color("light-blue"))
        .onAppear {
            self.gamesData.refreshData()
        }
        .navigationBarTitle(Text(self.gamesData.title))
    }
}

struct FixtureListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FixturesListView(
                gamesData: AllGamesData(fixtureManager: PreviewFixtureManager(), gameScoreManager: PreviewGameScoreManager(), useResults: false)
            )
        }
    }
}
