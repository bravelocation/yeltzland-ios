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
    let gameSettings = TVGameSettings()
    
    private var allGames = Array<TVFixtureData>()
    
    override init() {
        super.init();
        self.loadLatestData()
    }
    
    // Fetch the latest data
    func loadLatestData() {
        let currentGameAvailable = self.gameSettings.gameScoreForCurrentGame
        let nextGame = FixtureManager.instance.getNextGame()
        
        // Add next matches
        self.allGames.removeAll()
        
        for fixture in FixtureManager.instance.GetAllMatches() {
            if (currentGameAvailable && nextGame != nil && fixture === nextGame!) {
                // Is it an in-progress game
                self.allGames.append(TVFixtureData(opponent: fixture.displayOpponent,
                                                matchDate: fixture.tvResultDisplayKickoffTime,
                                                score: self.gameSettings.currentScore,
                                                inProgress: true,
                                                atHome: fixture.home))
            } else if (fixture.score.count == 0) {
                self.allGames.append(TVFixtureData(opponent: fixture.displayOpponent,
                                                matchDate: fixture.tvFixtureDisplayKickoffTime,
                                                score: fixture.score,
                                                inProgress: false,
                                                atHome: fixture.home))
            } else {
                var resultColor:UIColor = AppColors.TVResultText
                
                if (fixture.teamScore! > fixture.opponentScore!) {
                    resultColor = AppColors.TVFixtureWin
                } else if (fixture.teamScore! < fixture.opponentScore!) {
                    resultColor = AppColors.TVFixtureLose
                } else {
                    resultColor = AppColors.TVFixtureDraw
                }
                
                self.allGames.append(TVFixtureData(opponent: fixture.displayOpponent,
                                                matchDate: fixture.tvResultDisplayKickoffTime,
                                                score: fixture.score,
                                                inProgress: false,
                                                atHome: fixture.home,
                                                scoreColor:resultColor))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allGames.count    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:TVFixtureCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TVFixtureCollectionCell",
                                                                              for: indexPath) as! TVFixtureCollectionCell
 
        let dataItem = self.allGames[indexPath.row]
        cell.loadData(dataItem: dataItem)
                
        return cell;
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
            
            i = i + 1
        }
        
        // Just show first cell if all done
        return 0
    }
}
