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
    var extendedEntities: ExtendedEntities? { get }
    var quote: DisplayTweet? { get }
    
    var isRetweet: Bool { get }
    
    var userTwitterUrl: URL { get }
    var bodyTwitterUrl: URL { get }
}

protocol TweetEntity {
    var indices: [Int] { get }
    var displayText: String { get }
    var linkUrl: String? { get }
}

struct Tweet: Codable, Hashable, DisplayTweet {
    var id: String
    var fullText: String
    var user: User
    var createdAt: Date
    var entities: Entities
    var extendedEntities: ExtendedEntities?
    var retweet: Retweet?
    var quotedTweet: QuotedTweet?
    
    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case fullText = "full_text"
        case user = "user"
        case createdAt = "created_at"
        case entities = "entities"
        case extendedEntities = "extended_entities"
        case retweet = "retweeted_status"
        case quotedTweet = "quoted_status"
    }
    
    var isRetweet: Bool { return false }
    var quote: DisplayTweet? { return quotedTweet }
    var userTwitterUrl: URL { return URL(string: "https://twitter.com/\(self.user.screenName)")! }
    var bodyTwitterUrl: URL {
        let tweetUrl = "https://twitter.com/\(self.user.screenName)/status/\(self.id)"
        return URL(string: tweetUrl)!
    }
}

struct Retweet: Codable, Hashable, DisplayTweet {
    var id: String
    var fullText: String
    var user: User
    var createdAt: Date
    var entities: Entities
    var extendedEntities: ExtendedEntities?
    var quotedTweet: QuotedTweet?
    
    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case fullText = "full_text"
        case user = "user"
        case createdAt = "created_at"
        case entities = "entities"
        case extendedEntities = "extended_entities"
        case quotedTweet = "quoted_status"
    }
    
    var isRetweet: Bool { return true }
    var quote: DisplayTweet? { return quotedTweet }
    var userTwitterUrl: URL { return URL(string: "https://twitter.com/\(self.user.screenName)")! }
    var bodyTwitterUrl: URL {
        let tweetUrl = "https://twitter.com/\(self.user.screenName)/status/\(self.id)"
        return URL(string: tweetUrl)!
    }
}

struct QuotedTweet: Codable, Hashable, DisplayTweet {
    var id: String
    var fullText: String
    var user: User
    var createdAt: Date
    var entities: Entities
    var extendedEntities: ExtendedEntities?
    
    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case fullText = "full_text"
        case user = "user"
        case createdAt = "created_at"
        case entities = "entities"
        case extendedEntities = "extended_entities"
    }
    
    var isRetweet: Bool { return false }
    var quote: DisplayTweet? { return nil }
    var userTwitterUrl: URL { return URL(string: "https://twitter.com/\(self.user.screenName)")! }
    var bodyTwitterUrl: URL {
        let tweetUrl = "https://twitter.com/\(self.user.screenName)/status/\(self.id)"
        return URL(string: tweetUrl)!
    }
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
    
    enum CodingKeys: String, CodingKey {
        case hashtags
        case urls
        case userMentions = "user_mentions"
        case symbols = "symbols"
    }
}

struct ExtendedEntities: Codable, Hashable {
    var media: [Media]?
}

struct Hashtag: Codable, Hashable, TweetEntity {
    var text: String
    var indices: [Int]
    
    var displayText: String {
        return "#\(self.text)"
    }
    
    var linkUrl: String? {
        return "https://twitter.com/hashtag/\(self.text)"
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
        
        // Don't show URLs that start with https://twitter.com
        if (self.expandedUrl.starts(with: "https://twitter.com")) {
            return ""
        }
        
        return self.expandedUrl
    }
    
    var linkUrl: String? {
        return self.displayText
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
    
    var linkUrl: String? {
        return "https://twitter.com/\(self.screenName)"
    }
}

struct TweetSymbol: Codable, Hashable, TweetEntity {
    var text: String
    var indices: [Int]
    
    var displayText: String {
        return "$\(self.text)"
    }
    
    var linkUrl: String? {
        return nil
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
    
    var linkUrl: String? {
        return expandedUrl
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
