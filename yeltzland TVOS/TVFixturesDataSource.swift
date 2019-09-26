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
    private var allGames = Array<TVFixtureData>()
    
    override init() {
        super.init()
        self.loadLatestData()
    }
    
    // Fetch the latest data
    func loadLatestData() {
        var inProgressFixture: Fixture?
        
        if let currentFixture = GameScoreManager.shared.getCurrentFixture {
            if currentFixture.inProgress {
                inProgressFixture = currentFixture
            }
        }
        
        let nextGame = FixtureManager.shared.getNextGame()
        
        // Add next matches
        self.allGames.removeAll()
        
        for fixture in FixtureManager.shared.getAllMatches() {
            if (inProgressFixture != nil && nextGame != nil && fixture === nextGame!) {
                // Is it an in-progress game
                self.allGames.append(TVFixtureData(opponent: fixture.displayOpponent,
                                                matchDate: fixture.tvResultDisplayKickoffTime,
                                                score: inProgressFixture!.inProgressScore,
                                                inProgress: true,
                                                atHome: fixture.home))
            } else if (fixture.score.count == 0) {
                self.allGames.append(TVFixtureData(opponent: fixture.displayOpponent,
                                                matchDate: fixture.tvFixtureDisplayKickoffTime,
                                                score: fixture.score,
                                                inProgress: false,
                                                atHome: fixture.home))
            } else {
                var resultColor: UIColor = UIColor.white
                
                if (fixture.teamScore! > fixture.opponentScore!) {
                    resultColor = UIColor(named: "tv-fixture-win")!
                } else if (fixture.teamScore! < fixture.opponentScore!) {
                    resultColor = UIColor(named: "tv-fixture-lose")!
                } else {
                    resultColor = UIColor(named: "light-blue")!
                }
                
                self.allGames.append(TVFixtureData(opponent: fixture.displayOpponent,
                                                matchDate: fixture.tvResultDisplayKickoffTime,
                                                score: fixture.score,
                                                inProgress: false,
                                                atHome: fixture.home,
                                                scoreColor: resultColor))
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
            if (match.inProgress) {
                return i
            } else if (match.score.count == 0) {
                return i
            }
            
            i += 1
        }
        
        // Just show first cell if all done
        return 0
    }
}
