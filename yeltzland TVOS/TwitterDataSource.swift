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
    
    open static let TweetsNotification:String = "YLZTweetsNotification"

    let gameSettings = TVGameSettings()
    
    private var allTweets = Array<String>()
    
    override init() {
        super.init();
        self.loadLatestData()
    }
    
    // Fetch the latest data
    func loadLatestData() {
        allTweets.removeAll()
        
        // TODO: Load from Twitter API
        allTweets.append("ICYMI: tonight from 6.45pm we have a fans forum in the Grove, would be great to see as many of you there as possible")
        allTweets.append("BREAKING | We can now officialy confirm that unfortunately today's fixture at home to @halesowentownfc has been postponed due to a frozen pitch. We apologise for any inconvenience this has caused.")
        allTweets.append("Exodus at the Yeltz #EverywhereWeGo #UpTheYeltz https://www.ht-fc.co.uk/player-news")
        
        // Post notification message
        NotificationCenter.default.post(name: Notification.Name(rawValue: TwitterDataSource.TweetsNotification), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allTweets.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:TVTwitterCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TVTwitterCollectionCell",
                                                                              for: indexPath) as! TVTwitterCollectionCell
        
        let tweet = self.allTweets[indexPath.row]
        cell.loadData(tweet: tweet)
        
        return cell;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
