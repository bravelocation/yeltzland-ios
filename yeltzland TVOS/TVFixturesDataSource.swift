//
//  TVFixturesDataSource.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import Foundation
import UIKit

class TVFixturesDataSource: NSObject, UICollectionViewDataSource {
    private var allGames: [TimelineEntry] = []
    
    override init() {
        super.init()
        self.loadLatestData()
    }
    
    // Fetch the latest data
    func loadLatestData() {
        var inProgressFixture: Fixture?
        
        if let currentFixture = GameScoreManager.shared.currentFixture {
            if currentFixture.inProgress {
                inProgressFixture = currentFixture
            }
        }
        
        let nextGame = FixtureManager.shared.nextGame
        
        // Add next matches
        self.allGames.removeAll()
        
        for fixture in FixtureManager.shared.allMatches {
            if (inProgressFixture != nil && nextGame != nil && inProgressFixture == nextGame) {
                // Is it an in-progress game
                self.allGames.append(TimelineEntry(
                    opponent: fixture.opponent,
                    home: fixture.home,
                    date: fixture.fixtureDate,
                    teamScore: fixture.teamScore,
                    opponentScore: fixture.opponentScore,
                    status: .inProgress))
            } else if (fixture.teamScore == nil) {
                self.allGames.append(TimelineEntry(
                    opponent: fixture.opponent,
                    home: fixture.home,
                    date: fixture.fixtureDate,
                    teamScore: nil,
                    opponentScore: nil,
                    status: .fixture))
            } else {                
                self.allGames.append(TimelineEntry(
                    opponent: fixture.opponent,
                    home: fixture.home,
                    date: fixture.fixtureDate,
                    teamScore: fixture.teamScore,
                    opponentScore: fixture.opponentScore,
                    status: .result))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allGames.count    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TVFixtureCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TVFixtureCollectionCell",
                                                                              for: indexPath) as! TVFixtureCollectionCell
 
        let dataItem = self.allGames[indexPath.row]
        cell.loadData(dataItem: dataItem)
                
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func indexOfFirstFixture() -> Int {
        var i = 0
        
        for match in self.allGames {
            if (match.status == .inProgress || match.status == .fixture) {
                return i
            }
            
            i += 1
        }
        
        // Just show first cell if all done
        return 0
    }
}
