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

    private let gameSettings = TVGameSettings()
    private let twitterConsumerKey = "8G26YU7skH5dgbvXx5nwk0G0u"
    private let twitterConsumerSecret = "kUMwYAiDNR7dGjvSsTnHH20tXcutxEzkwycYJA68Darig6pRYz"
    private let twitterAuthURL = "https://api.twitter.com/oauth2/token"
    private let userTimelineURL = "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=halesowentownfc&count=10&trim_user=1&tweet_mode=extended"
    private var allTweets = Array<String>()
    
    override init() {
        super.init();
        self.loadLatestData()
    }
    
    // Fetch the latest data
    func loadLatestData() {
        // Load from Twitter API
        self.authenticateRequest(self.userTimelineURL)
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
    
    // MARK: App only Auth tasks for Twitter
    // extracted from https://github.com/rshankras/SwiftDemo
    
    func getBearerToken(_ completion: @escaping (_ bearerToken: String) ->Void) {
        var request = URLRequest(url: URL(string: self.twitterAuthURL)!)
        
        request.httpMethod = "POST"
        request.addValue("Basic " + self.getBase64EncodeString(), forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let grantType =  "grant_type=client_credentials"
        
        request.httpBody = grantType.data(using: String.Encoding.utf8, allowLossyConversion: true)

        // Don't cache any responses
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        let session = URLSession.init(configuration: config)
        
        session.dataTask(with: request) { data, response, error in
            
            guard let authData = data else {
                print(error?.localizedDescription ?? "Error fetching authentication data")
                return
            }
            
            do {
                let results: NSDictionary = try JSONSerialization.jsonObject(with: authData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                if let token = results["access_token"] as? String {
                    completion(token)
                } else {
                    print(results["errors"] ?? "Error fetching authentication token")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            }.resume()
    }
    
    func getBase64EncodeString() -> String {
        let consumerKeyRFC1738 = self.twitterConsumerKey.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        let consumerSecretRFC1738 = self.twitterConsumerSecret.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        let concatenateKeyAndSecret = consumerKeyRFC1738! + ":" + consumerSecretRFC1738!
        let secretAndKeyData = concatenateKeyAndSecret.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let base64EncodeKeyAndSecret = secretAndKeyData?.base64EncodedString(options: NSData.Base64EncodingOptions())
        
        return base64EncodeKeyAndSecret!
    }
    
    func authenticateRequest(_ url:String) {        
        // if using twitter, use this method. Add more auth methods if necessary, later
        self.getBearerToken { bearerToken in
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "GET"
            
            let token = "Bearer " + bearerToken
            request.addValue(token, forHTTPHeaderField: "Authorization")

            // Don't cache any responses
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            config.urlCache = nil
            let session = URLSession.init(configuration: config)
            
            session.dataTask(with: request) { data, response, error in
                if let validData = data , error == nil {
                    do {
                        if let results = try JSONSerialization.jsonObject(with: validData, options: JSONSerialization.ReadingOptions.allowFragments) as? Array<Any> {
                            self.processUserTweets(results)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                } else {
                    print(error?.localizedDescription ?? "Error parsing user tweets")
                }
                }.resume()
        }
    }
    
    func processUserTweets(_ results: Array<Any>) {
        self.allTweets.removeAll()
        
        // Parse the array
        for result in results {
            if let tweetDictionary = result as? [String: Any] {
                if let tweetText = tweetDictionary["full_text"] as? String {
                    self.allTweets.append(tweetText)
                }
            }
        }
        
        // Post notification message
        NotificationCenter.default.post(name: Notification.Name(rawValue: TwitterDataSource.TweetsNotification), object: nil)
    }
}
