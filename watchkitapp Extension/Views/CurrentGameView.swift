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
        
                Text(gameStatus(data.latest))
                    .lineLimit(2)
                    .font(.footnote)
                
                self.data.teamImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.logoDim, height: self.logoDim, alignment: .center)
                
                Text(opponentText(data.latest))
                    .lineLimit(2)
                    .font(.body)
                
                Text(scoreOrDate(data.latest))
                    .font(scoreOrDateFont(data.latest))
                    .foregroundColor(self.data.resultColor)

                Spacer()
            }
            .foregroundColor(Color("light-blue"))
            .padding()
            
            Spacer()
        }
        .padding()
        .overlay(
            Button(action: {
                self.data.refreshData()
            }, label: {
                Image(systemName: "arrow.clockwise")
                    .font(.footnote)
                    .foregroundColor(Color.gray)

            })
            .frame(width: 24.0, height: 24.0, alignment: .center)
            .background(Color("light-blue").opacity(0.2))
            .cornerRadius(12), alignment: .bottomTrailing
        )
        .onAppear {
            self.data.refreshData()
        }
        .navigationBarTitle(Text(data.title))
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
                return "LATEST SCORE"
            case .fixture:
                return "NEXT GAME"
            }
        }
        
        return ""
    }
    
    func scoreOrDate(_ entry: TimelineEntry?) -> String {
        
        if let entry = entry {
            switch (entry.status) {
            case .result:
                return entry.displayScore
            case .inProgress:
                return "\(entry.displayScore)*"
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
