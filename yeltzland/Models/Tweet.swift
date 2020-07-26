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
    var urls: [TweetUrl]
    var userMentions: [UserMention]
    var symbols: [TweetSymbol]
    var media: [Media]?
    
    enum CodingKeys: String, CodingKey {
        case hashtags
        case urls
        case userMentions = "user_mentions"
        case symbols = "symbols"
        case media
    }
}

struct Hashtag: Codable, Hashable, TweetEntity {
    var text: String
    var indices: [Int]
    
    var displayText: String {
        return "#\(self.text)"
    }
}

struct TweetUrl: Codable, Hashable, TweetEntity {
    var url: String
    var displayUrl: String
    var expandedUrl: String
    var indices: [Int]
    
    enum CodingKeys: String, CodingKey {
        case url
        case displayUrl = "display_url"
        case expandedUrl = "expanded_url"
        case indices
    }
    
    var displayText: String {
        return self.expandedUrl
    }
}

struct UserMention: Codable, Hashable, TweetEntity {
    var name: String
    var screenName: String
    var id: String
    var indices: [Int]
    
    enum CodingKeys: String, CodingKey {
        case name
        case screenName = "screen_name"
        case id = "id_str"
        case indices
    }
    
    var displayText: String {
        return "@\(self.screenName)"
    }
}

struct TweetSymbol: Codable, Hashable, TweetEntity {
    var text: String
    var indices: [Int]
    
    var displayText: String {
        return "$\(self.text)"
    }
}

struct Media: Codable, Hashable, TweetEntity {
    var id: String
    var displayUrl: String
    var expandedUrl: String
    var mediaUrl: String
    var sizes: MediaSizes
    var indices: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case displayUrl = "display_url"
        case expandedUrl = "expanded_url"
        case mediaUrl = "media_url_https"
        case sizes
        case indices
    }
    
    var displayText: String {
        return "" // Hide the media URL in the tweet, as we will load images directly
    }
}

struct MediaSizes: Codable, Hashable {
    var thumb: MediaSize
    var large: MediaSize
    var medium: MediaSize
    var small: MediaSize
}

struct MediaSize: Codable, Hashable {
    var height: Int
    var resize: String
    var width: Int
    
    enum CodingKeys: String, CodingKey {
        case height = "h"
        case resize = "resize"
        case width = "w"
    }
}
