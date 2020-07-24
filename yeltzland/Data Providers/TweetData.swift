//
//  TweetData.swift
//  yeltzland
//
//  Created by John Pollard on 24/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 13.0, *)
class TweetData: ObservableObject {
    
    @Published var tweets: [Tweet] = []
    
    var dataProvider: TwitterDataProviderProtocol
    
    init(dataProvider: TwitterDataProviderProtocol) {
        self.dataProvider = dataProvider
        
        self.refreshData()
    }
    
    public func refreshData() {
        self.dataProvider.refreshData()
        self.tweets = self.dataProvider.tweets
    }
}
