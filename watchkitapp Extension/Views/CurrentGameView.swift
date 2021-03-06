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
            VStack {
                Group {
                    if (data.latest != nil) {
                        if (data.latest!.status == .fixture) {
                            FixtureView(fixture: self.data.latest!, teamImage: self.data.teamImage)
                        } else {
                            ResultView(fixture: self.data.latest!, teamImage: self.data.teamImage, resultColor: self.data.resultColor)
                        }
                    } else {
                        Text("No games").padding()
                    }
                }
                
                Spacer()
            }
            Spacer()
        }
        .overlay(
            Button(action: {
                self.data.refreshData()
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
            self.data.refreshData()
        }
        .navigationBarTitle(Text(self.navTitle()))
    }
    
    func navTitle() -> String {
        if self.data.state == .isLoading {
            return "Loading..."
        }
        
        if let fixture = self.data.latest {
            switch fixture.status {
            case .fixture:
                return "Next game"
            case .inProgress:
                return "Latest Score"
            case .result:
                return "Result"
            }
        }
        
        return "Yeltzland"
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
