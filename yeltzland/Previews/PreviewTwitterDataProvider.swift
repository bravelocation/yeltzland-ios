//
//  PreviewTwitterDataProvider.swift
//  yeltzland
//
//  Created by John Pollard on 24/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

class PreviewTwitterDataProvider: TwitterDataProviderProtocol {
    var tweets: [Tweet] {
        var testTweets: [Tweet] = []
        
        testTweets.append(
            Tweet(id: "1286327578949832704",
                  fullText: "Test tweet 1",
                  user: User(name: "Halesowen Town FC",
                             screenName: "halesowentownfc",
                             profileImageUrl: "https://pbs.twimg.com/profile_images/1195108198715400192/TMrPMD8B_normal.jpg"),
                  createdAt: Date(),
                  entities: Entities(
                                hashtags: [],
                                urls: [],
                                userMentions: [],
                                symbols: []
                            )
            )
        )
        
        return testTweets
    }
    
    func refreshData() {
        // Post notification message
        NotificationCenter.default.post(name: Notification.Name(rawValue: TwitterDataProvider.TweetsNotification), object: nil)
    }
}
