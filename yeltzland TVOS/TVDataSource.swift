//
//  TVDataSource.swift
//  yeltzland TVOS
//
//  Created by John Pollard on 11/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import Foundation

import UIKit

class TVDataSource: NSObject, UICollectionViewDataSource {
    let gameSettings = TVGameSettings()
    
    private var allGames = Array<TVDataItem>()
    
    override init() {
        super.init();
        self.loadLatestData()
    }
    
    // Fetch the latest data
    func loadLatestData() {
        let currentGameAvailable = self.gameSettings.gameScoreForCurrentGame;

        // Add next matches
        self.allGames.removeAll()
        
        for fixture in FixtureManager.instance.GetAllMatches() {
            if (currentGameAvailable && fixture.teamScore == nil && fixture.opponentScore == nil && self.gameSettings.currentGameTime == fixture.fixtureDate) {
                // Is it an in-progress game
                self.allGames.append(TVDataItem(opponent: fixture.displayOpponent, matchDate: fixture.fullDisplayKickoffTime, score: self.gameSettings.currentScore, inProgress: true))
            } else {
                self.allGames.append(TVDataItem(opponent: fixture.displayOpponent, matchDate: fixture.fullDisplayKickoffTime, score: fixture.score, inProgress: false))
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
