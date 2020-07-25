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
import SDWebImage

@available(iOS 13.0, *)
class TweetData: ObservableObject {
    
    @Published var tweets: [Tweet] = []
    @Published var profilePics: [String: UIImage] = [:]
    @Published var accountName: String = ""
    
    var dataProvider: TwitterDataProviderProtocol
    
    init(dataProvider: TwitterDataProviderProtocol, accountName: String) {
        self.dataProvider = dataProvider
        self.accountName = accountName
        
        //Add notification handler for updating on updated tweets
        NotificationCenter.default.addObserver(self, selector: #selector(TweetData.dataUpdated(_:)), name: NSNotification.Name(rawValue: TwitterDataProvider.TweetsNotification), object: nil)
        
        self.refreshData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func refreshData() {
        self.dataProvider.refreshData()
    }
    
    private func reloadTweets() {
        self.tweets.removeAll()
        self.tweets.append(contentsOf: self.dataProvider.tweets)
        
        for tweet in self.tweets {
            self.fetchProfilePic(screenName: tweet.user.screenName, profileImageUrl: tweet.user.profileImageUrl)
            
            if let retweet = tweet.retweet {
                self.fetchProfilePic(screenName: retweet.user.screenName, profileImageUrl: retweet.user.profileImageUrl)
            }
        }
    }
    
    func profilePic(_ screenName: String) -> Image {
        if let image = self.profilePics[screenName] {
            return Image(uiImage: image)
        }
        
        return Image(systemName: "person.circle")
    }
    
    private func fetchProfilePic(screenName: String, profileImageUrl: String) {
        if self.profilePics[screenName] != nil {
            return
        }
        
        self.loadUserProfileImage(profileImageUrl: profileImageUrl) { image in
            if image != nil {
                self.profilePics[screenName] = image
            }
        }
    }
    
    private func loadUserProfileImage(profileImageUrl: String, completion: @escaping (UIImage?) -> Void) {
        if let profileUrl = URL(string: profileImageUrl) {
            SDWebImageManager.shared.loadImage(with: profileUrl,
                                           options: .continueInBackground,
                                           progress: nil) { image, _, _, _, _, _  in
                                                completion(image)
                                            }
        } else {
            completion(nil)
        }
    }
    
    @objc
    fileprivate func dataUpdated(_ notification: Notification) {
        // Update fixtures data on main thread
        DispatchQueue.main.async {
            self.reloadTweets()
        }
    }
}
