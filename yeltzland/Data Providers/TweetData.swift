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
    @Published var images: [String: UIImage] = [:]
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
            self.fetchTweetImages(tweet: tweet)
            
            if let retweet = tweet.retweet {
                self.fetchTweetImages(tweet: retweet)
            }
        }
    }
    
    func profilePic(_ tweet: DisplayTweet) -> Image {
        if let image = self.images[tweet.user.profileImageUrl] {
            return Image(uiImage: image)
        }
        
        return Image(systemName: "person.circle")
    }
    
    func tweetImage(_ media: Media?) -> Image? {
        if let media = media {
            if let imageUrl = media.smallImageUrl, let image = self.images[imageUrl] {
                return Image(uiImage: image)
            }
        }
        
        return Image("no-tweet-image")
    }
    
    private func fetchTweetImages(tweet: DisplayTweet) {
        // Fetch profile image
        if self.images[tweet.user.profileImageUrl] == nil {
            self.loadImage(profileImageUrl: tweet.user.profileImageUrl) { image in
                if image != nil {
                    self.images[tweet.user.profileImageUrl] = image
                }
            }
        }
        
        // Fetch tweet images
        if let mediaParts = tweet.entities.media {
            for media in mediaParts {
                if let imageUrl = media.smallImageUrl {
                    if self.images[imageUrl] == nil {
                        self.loadImage(profileImageUrl: imageUrl) { image in
                            if image != nil {
                                self.images[imageUrl] = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func loadImage(profileImageUrl: String, completion: @escaping (UIImage?) -> Void) {
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
