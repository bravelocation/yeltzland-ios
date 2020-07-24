//
//  Tweet.swift
//  yeltzland
//
//  Created by John Pollard on 24/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

struct Tweet: Codable, Hashable {
    var id: String
    var fullText: String
    var user: User
    
    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case fullText = "full_text"
        case user = "user"
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
