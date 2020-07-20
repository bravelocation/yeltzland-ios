//
//  CurrentGameView.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import SwiftUI

struct CurrentGameView: View {
    @ObservedObject var data: CurrentGameData
    
    let logoDim = CGFloat(40)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                self.data.teamImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.logoDim, height: self.logoDim, alignment: .center)
                
                Text(opponentText(data.latest))
                    .lineLimit(2)
                    .font(.body)
                
                Text(scoreOrDate(data.latest))
                    .font(scoreOrDateFont(data.latest))
                
                Text(gameStatus(data.latest))
                    .lineLimit(2)
                    .font(.footnote)
                
                Spacer()
            }
                .foregroundColor(Color("light-blue"))
                .padding()
            
            Spacer()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
            .stroke(Color("light-blue"), lineWidth: 2)
        )
        .padding()
        .contextMenu(menuItems: {
            Button(action: {
                self.data.refreshData()
            }, label: {
                VStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                    Text("Refresh data")
                }
            })
        })
        .onAppear {
            self.data.refreshData()
        }
    }
    
    func opponentText (_ entry: TimelineEntry?) -> String {
        if let entry = entry {
            return entry.displayOpponent
        }
        
        return "No more games"
    }
    
    func gameStatus(_ entry: TimelineEntry?) -> String {
        if let entry = entry {
            switch (entry.status) {
            case .result:
                return "RESULT"
            case .inProgress:
                return "* BASED ON TWITTER"
            case .fixture:
                return ""
            }
        }
        
        return ""
    }
    
    func scoreOrDate(_ entry: TimelineEntry?) -> String {
        
        if let entry = entry {
            switch (entry.status) {
            case .result:
                return "\(entry.teamScore ?? 0)-\(entry.opponentScore ?? 0)"
            case .inProgress:
                return "\(entry.teamScore ?? 0)-\(entry.opponentScore ?? 0)*"
            case .fixture:
                return entry.fullDisplayKickoffTime
            }
        }
        
        return ""
    }
    
    func scoreOrDateFont(_ entry: TimelineEntry?) -> Font {
        if let entry = entry {
            switch (entry.status) {
            case .result, .inProgress:
                return .largeTitle
            case .fixture:
                let kickoffTime = entry.fullDisplayKickoffTime
                return kickoffTime.count > 6 ? .headline : .largeTitle
            }
        }
        
        return .body
    }
}

struct NextGameView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentGameView(data: CurrentGameData(
            fixtureManager: PreviewFixtureManager(),
            gameScoreManager: PreviewGameScoreManager())
        )
    }
}
