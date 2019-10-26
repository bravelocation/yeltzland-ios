//
//  NextGameView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import SwiftUI

struct NextGameView: View {
    @ObservedObject var fixtureData = FixtureListData()
    
    let logoDim = CGFloat(40)
    
    var body: some View {
        VStack {
            Text(isInProgress(fixtureData.latest) ? "Latest Score" : "Final Score")
                .font(.headline)
                .foregroundColor(Color("light-blue"))

            HStack {
                self.fixtureData.teamImage(self.teamImageName(fixture: fixtureData.latest, homeTeam: true))
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.logoDim, height: self.logoDim, alignment: .center)
                self.fixtureData.teamImage(self.teamImageName(fixture: fixtureData.latest, homeTeam: false))
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.logoDim, height: self.logoDim, alignment: .center)
            }
            Text(fixtureData.latest?.displayOpponent ?? "No more games")
            Text(isInProgress(fixtureData.latest) ? unwrapString(fixtureData.latest?.inProgressScore) : unwrapString(fixtureData.latest?.score))
                .foregroundColor(self.fixtureData.resultColor(fixtureData.latest))
            Spacer()
            Text(isInProgress(fixtureData.latest) ? "* Best guess from Twitter" : "")
                .font(.footnote)
                .multilineTextAlignment(.trailing)
        }
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
    
    func unwrapString(_ val: String?) -> String {
        if let val = val {
            return val
        }
        
        return ""
    }
    
    func isInProgress(_ fixture: Fixture?) -> Bool {
        if let fixture = fixture {
            return fixture.inProgress
        }
        
        return false
    }
    
    func teamImageName(fixture: Fixture?, homeTeam: Bool) -> String {
        if let fixture = fixture {
            if fixture.home == true && homeTeam == false {
                return fixture.opponentNoCup
            } else if fixture.home == false && homeTeam == true {
               return fixture.opponentNoCup
            }
        }
        
        return "Halesowen Town"
    }
}

struct NextGameView_Previews: PreviewProvider {
    static var previews: some View {
        NextGameView()
    }
}
