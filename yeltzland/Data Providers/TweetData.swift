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
        NotificationCenter.default.addObserver(self, selector: #selector(TweetData.dataUpdated(_:)), name: .TweetsUpdated, object: nil)
        
        self.refreshData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func refreshData() {
        self.dataProvider.refreshData()
    }
    
    private func reloadTweets() {
        // Update fixtures data on main thread
        DispatchQueue.main.async {
            self.tweets.removeAll()
            self.tweets.append(contentsOf: self.dataProvider.tweets)
            
            for tweet in self.tweets {
                self.fetchTweetImages(tweet: tweet)
                
                if let retweet = tweet.retweet {
                    self.fetchTweetImages(tweet: retweet)
                }
            }
        }
    }
    
    func profilePic(_ tweet: DisplayTweet) -> Image {
        if let image = self.images[tweet.user.profileImageUrl] {
            return Image(uiImage: image)
        }
        
        return Image(systemName: "person.circle")
    }
    
    func tweetImage(_ media: Media?) -> Image {
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
            self.loadImage(imageUrl: tweet.user.profileImageUrl) { image in
                if let image = image {
                    self.addImageToCache(key: tweet.user.profileImageUrl, image: image)
                }
            }
        }
        
        // Fetch tweet images
        for media in tweet.allMedia {
            if let imageUrl = media.smallImageUrl {
                if self.images[imageUrl] == nil {
                    self.loadImage(imageUrl: imageUrl) { image in
                        if let image = image {
                            self.addImageToCache(key: imageUrl, image: image)
                        }
                    }
                }
            }
        }
        
        // Fetch quoted tweet images
        if let mediaParts = tweet.quote?.allMedia {
            for media in mediaParts {
                if let imageUrl = media.smallImageUrl {
                    if self.images[imageUrl] == nil {
                        self.loadImage(imageUrl: imageUrl) { image in
                            if let image = image {
                                self.addImageToCache(key: imageUrl, image: image)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func loadImage(imageUrl: String, completion: @escaping (UIImage?) -> Void) {
        if let loadUrl = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: loadUrl,
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
        self.reloadTweets()
    }
    
    private func addImageToCache(key: String, image: UIImage) {
        // Update images on main thread
        DispatchQueue.main.async {
            self.images[key] = image
        }
    }
}
