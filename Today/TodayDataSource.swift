//
//  TodayDataSource.swift
//  yeltzland
//
//  Created by John Pollard on 28/05/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit

class TodayDataSource: NSObject, UICollectionViewDataSource {

    private var timelineManager: TimelineManager
    private var timelineEntries: [TimelineEntry]
    
    override init() {
        // TODO: Don't forget to switch this back to the real provider before release
        //self.timelineManager = TimelineManager(fixtureManager: FixtureManager.shared, gameScoreManager: GameScoreManager.shared)
        self.timelineManager = TimelineManager(fixtureManager: MockFixtureManager(), gameScoreManager: MockGameScoreManager())
        
        self.timelineEntries = self.timelineManager.timelineEntries
        
        super.init()
    }
    
    func reloadData() {
        self.timelineManager.reloadData()
    }
    
    // MARK: - Collection view data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.timelineEntries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayViewController.cellReuseIdentifier, for: indexPath) as! TodayFixtureCollectionViewCell
        
        // Figure out data to show
        var entry: TimelineEntry?
        
        if (self.timelineEntries.count >= indexPath.row) {
            entry = self.timelineEntries[indexPath.row]
        }
        
        if let entry = entry {
            cell.updateData(entry)
        }
        
        // Configure the cell
        return cell
    }
}
