//
//  Tweet.swift
//  yeltzland
//
//  Created by John Pollard on 24/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

protocol DisplayTweet {
    var id: String { get }
    var fullText: String { get }
    var user: User { get }
    var createdAt: Date { get }
    var entities: Entities { get }
    
    var isRetweet: Bool { get }
}

protocol TweetEntity {
    var indices: [Int] { get }
    var displayText: String { get }
}

struct Tweet: Codable, Hashable, DisplayTweet {
    var id: String
    var fullText: String
    var user: User
    var createdAt: Date
    var entities: Entities
    var retweet: Retweet?
    
    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case fullText = "full_text"
        case user = "user"
        case createdAt = "created_at"
        case entities = "entities"
        case retweet = "retweeted_status"
    }
    
    var isRetweet: Bool { return false }
}

struct Retweet: Codable, Hashable, DisplayTweet {
    var id: String
    var fullText: String
    var user: User
    var createdAt: Date
    var entities: Entities
    
    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case fullText = "full_text"
        case user = "user"
        case createdAt = "created_at"
        case entities = "entities"
    }
    
    var isRetweet: Bool { return true }
}

struct User: Codable, Hashable {
    var name: String
    var screenName: String
    var profileImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case screenName = "screen_name"
        case profileImageUrl = "profile_image_url_https"
    }
}

struct Entities: Codable, Hashable {
    var hashtags: [Hashtag]
}

struct Hashtag: Codable, Hashable, TweetEntity {
    var text: String
    var indices: [Int]
    
    var displayText: String {
        return "#\(self.text)"
    }
}
