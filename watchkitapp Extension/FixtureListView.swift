//
//  FixtureListView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct FixtureListView: View {
    @ObservedObject var fixtureData = FixtureListData()
    
    var body: some View {
        List(self.fixtureData.fixtures, id: \.self) { fixture in

            VStack(alignment: .leading) {
                HStack {
                    WebImage(url: TeamImageManager.shared.teamURL(fixture.opponent))
                        .resizable()
                        .scaledToFit()
                        .frame(width: CGFloat(50), height: CGFloat(50), alignment: .center)
                    Spacer()
                    Text(fixture.tvResultDisplayKickoffTime)
                }
                Text(fixture.displayOpponent)
                    .lineLimit(2)
                Text(fixture.score)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(self.resultColor(fixture))
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
    
    func resultColor(_ fixture: Fixture) -> Color {
        let teamScore = fixture.teamScore
        let opponentScore  = fixture.opponentScore
         
        if (teamScore != nil && opponentScore != nil) {
             if (teamScore! > opponentScore!) {
                return Color("watch-fixture-win")
             } else if (teamScore! < opponentScore!) {
                return Color("watch-fixture-lose")
             }
        }
        
        return Color.white
    }
    
}

struct FixtureListView_Previews: PreviewProvider {
    static var previews: some View {
        FixtureListView()
    }
}

/*

 TeamImageManager.shared.loadTeamImage(teamName: fixture.opponent, view: self.teamImage)

 self.labelScore?.setTextColor(resultColor)
 */
