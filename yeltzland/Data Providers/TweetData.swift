//
//  TweetData.swift
//  yeltzland
//
//  Created by John Pollard on 24/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import SDWebImage

#if canImport(SwiftUI)
import SwiftUI
import Combine
#endif

@available(iOS 13.0, *)
class TweetData: ObservableObject {
    
    enum State {
        case isLoading
        case loaded
    }
    
    @Published var tweets: [Tweet] = []
    @Published var images: [String: UIImage] = [:]
    @Published var accountName: String = ""
    @Published var state: State = State.isLoading
    
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
        self.setState(.isLoading)
        self.dataProvider.refreshData()
    }
    
    private func setState(_ state: State) {
        DispatchQueue.main.async {
            self.state = state
        }
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
            
            self.setState(.loaded)
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
        self.fetchImagesForMediaParts(tweet.allMedia)
        
        // Fetch quoted tweet images
        if let mediaParts = tweet.quote?.allMedia {
            self.fetchImagesForMediaParts(mediaParts)
        }
    }
    
    private func fetchImagesForMediaParts(_ mediaParts: [Media]) {
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
