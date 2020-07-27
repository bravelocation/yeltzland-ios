//
//  TwitterDataProvider.swift
//  yeltzland
//
//  Created by John Pollard on 24/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

protocol TwitterDataProviderProtocol {
    var tweets: [Tweet] { get }
    func refreshData()
}

extension Notification.Name {
    static let TweetsUpdated = Notification.Name(rawValue: "YLZTweetsNotification")
}

class TwitterDataProvider: TwitterDataProviderProtocol {
    private var twitterConsumerKey: String
    private var twitterConsumerSecret: String
    private var accountName: String
    private var tweetCount: Int
    
    private var allTweets: [Tweet] = []
    
    init(twitterConsumerKey: String, twitterConsumerSecret: String, tweetCount: Int = 10, accountName: String = "halesowentownfc") {
        self.twitterConsumerKey = twitterConsumerKey
        self.twitterConsumerSecret = twitterConsumerSecret
        self.tweetCount = tweetCount
        self.accountName = accountName
        
        self.refreshData()
    }
    
    public var tweets: [Tweet] {
        get {
            return self.allTweets
        }
    }
    
    public func refreshData() {
        // Load from Twitter API
        let userTimelineURL = "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=\(self.accountName)&count=\(self.tweetCount)&exclude_replies=true&tweet_mode=extended"
        self.authenticateRequest(userTimelineURL)
    }
    
    // MARK: App only Auth tasks for Twitter
    // extracted from https://github.com/rshankras/SwiftDemo
    
    func getBearerToken(_ completion: @escaping (_ bearerToken: String) -> Void) {
        let twitterAuthURL = "https://api.twitter.com/oauth2/token"
        var request = URLRequest(url: URL(string: twitterAuthURL)!)
        
        request.httpMethod = "POST"
        request.addValue("Basic " + self.getBase64EncodeString(), forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let grantType =  "grant_type=client_credentials"
        
        request.httpBody = grantType.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let session = URLSession.shared
        
        session.dataTask(with: request) { data, _, error in
            
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
    
    func authenticateRequest(_ url: String) {
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
            
            session.dataTask(with: request) { data, _, error in
                if let validData = data, error == nil {
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    do {
                        let results = try decoder.decode([Tweet].self, from: validData)
                        self.processUserTweets(results)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                } else {
                    print(error?.localizedDescription ?? "Error parsing user tweets")
                }
                }.resume()
        }
    }
    
    func processUserTweets(_ results: Array<Tweet>) {
        DispatchQueue.main.async {
            self.allTweets.removeAll()
            self.allTweets.append(contentsOf: results)
            
            // Post notification message
            NotificationCenter.default.post(name: .TweetsUpdated, object: nil)
        }
    }
}
