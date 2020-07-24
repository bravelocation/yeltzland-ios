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
        
        testTweets.append(Tweet(id: "1286327578949832704", fullText: "Test tweet 1"))
        testTweets.append(Tweet(id: "1286229541627756544", fullText: "Test tweet 2"))
        
        return testTweets
    }
    
    func refreshData() {
        // Do nothing
    }
}
