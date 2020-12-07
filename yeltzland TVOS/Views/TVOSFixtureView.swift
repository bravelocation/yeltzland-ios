//
//  FixtureView.swift
//  Yeltzland
//
//  Created by John Pollard on 06/12/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

struct TVOSFixtureView: View {
    @EnvironmentObject var fixtureData: FixtureData
    @State private var borderColor = Color.clear
    var fixture: TimelineFixture
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                self.fixtureData.teamPic(self.fixture)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64, alignment: .center)
                .cornerRadius(32)
                
                Text(self.fixture.opponentPlusHomeAway)
                
                Spacer()
                
                if (fixture.status == .fixture) {
                    Text(fixture.kickoffTime)
                } else {
                    Text(fixture.score)
                        .foregroundColor(self.resultColor())
                }
            }
        }
        .focusable(true) { isFocused in
            self.borderColor = isFocused ? Color.yellow : Color.clear
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(self.borderColor, lineWidth: 1)
        )
    }
    
    func resultColor() -> Color {
        switch self.fixture.result {
        case .win:
            return Color("watch-fixture-win")
        case .lose:
            return Color("watch-fixture-lose")
        default:
            return Color("light-blue")
        }
    }
}

struct TVOSFixtureView_Previews: PreviewProvider {
    static var previews: some View {
        TVOSFixtureView(fixture: TimelineFixture(opponent: "Barnet",
                                             home: false,
                                             date: Date(),
                                             teamScore: 2,
                                             opponentScore: 1,
                                             status: .result))
            .environmentObject(FixtureData())
    }
}
