//
//  TwitterDataSource.swift
//  yeltzlandTVOS
//
//  Created by John Pollard on 19/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import Foundation
import UIKit

class TwitterDataSource: NSObject, UICollectionViewDataSource {
    
    private var dataProvider: TwitterDataProvider
    
    override init() {
        let settings = SettingsManager.shared
        let twitterConsumerKey = settings.getSetting("TwitterConsumerKey") as! String
        let twitterConsumerSecret = settings.getSetting("TwitterConsumerSecret") as! String
        
        self.dataProvider = TwitterDataProvider(twitterConsumerKey: twitterConsumerKey, twitterConsumerSecret: twitterConsumerSecret)
        super.init()
        
        self.loadLatestData()
    }
    
    // Fetch the latest data
    func loadLatestData() {
        self.dataProvider.refreshData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataProvider.tweets.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TVTwitterCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TVTwitterCollectionCell",
                                                                              for: indexPath) as! TVTwitterCollectionCell
        
        let tweet = self.dataProvider.tweets[indexPath.row]
        cell.loadData(tweet: tweet.fullTweet)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
