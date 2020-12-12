//
//  TwitterHostingController.swift
//  Yeltzland
//
//  Created by John Pollard on 20/11/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0, *)
class TwitterHostingController<Content: View>: UIHostingController<Content> {

    let tweetData: TweetData

    init(twitterAccountName: String) {
        
        let twitterConsumerKey = SettingsManager.shared.getSetting("TwitterConsumerKey") as! String
        let twitterConsumerSecret = SettingsManager.shared.getSetting("TwitterConsumerSecret") as! String
        
        let twitterDataProvider = TwitterDataProvider(
            twitterConsumerKey: twitterConsumerKey,
            twitterConsumerSecret: twitterConsumerSecret,
            tweetCount: 50,
            accountName: twitterAccountName
        )
        
        self.tweetData = TweetData(dataProvider: twitterDataProvider, accountName: twitterAccountName)
        
        let rootView = AnyView(TwitterView().environmentObject(tweetData))

        super.init(rootView: rootView as! Content)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Keyboard options
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "Reload", action: #selector(TwitterHostingController.reloadButtonTouchUp), input: "R", modifierFlags: .command)
        ]
    }
    
    @objc func reloadButtonTouchUp() {
        print("Reloading tweet data from keyboard command ...")
        self.tweetData.refreshData()
    }
}
