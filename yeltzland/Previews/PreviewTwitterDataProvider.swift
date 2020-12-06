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
        
        let testTweet = Tweet(id: "1286327578949832704",
          fullText: "ICYMI: Copies of YELTZMEN can be pre-ordered up until 5pm on Saturday 25th July at the reduced price of £12.99 https://t.co/jtzAOR5yjJ #UpTheYeltz https://t.co/R1xNPbQAvM",
          user: User(name: "Halesowen Town FC",
                     screenName: "halesowentownfc",
                     profileImageUrl: "https://pbs.twimg.com/profile_images/1195108198715400192/TMrPMD8B_normal.jpg"),
          createdAt: Date(),
          entities: Entities(
                        hashtags: [Hashtag(text: "UpTheYeltz", indices: [135, 146])],
                        urls: [TweetUrl(url: "https://t.co/jtzAOR5yjJ",
                                        displayUrl: "ht-fc.co.uk/yeltzmen-book-\\u2026",
                                        expandedUrl: "https://www.ht-fc.co.uk/yeltzmen-book-launch",
                                        indices: [111, 134])],
                        userMentions: [],
                        symbols: []
                    ),
            extendedEntities: ExtendedEntities(media: [
                Media(id: "1286327220433231880",
                      displayUrl: "pic.twitter.com/R1xNPbQAvM",
                      expandedUrl: "https://twitter.com/halesowentownfc/status/1286327578949832704/photo/1",
                      mediaUrl: "https://pbs.twimg.com/media/Ednzyq7WoAghlfJ.jpg",
                      sizes: MediaSizes(
                        thumb: MediaSize(height: 150, resize: "crop", width: 150),
                        large: MediaSize(height: 1598, resize: "fit", width: 1600),
                        medium: MediaSize(height: 1199, resize: "fit", width: 1200),
                        small: MediaSize(height: 679, resize: "fit", width: 680)),
                      indices: [147, 170])
            ])
        )
        
        testTweets.append(testTweet)
        
        return testTweets
    }
    
    func refreshData() {
        // Post notification message
        NotificationCenter.default.post(name: .TweetsUpdated, object: nil)
    }
}
