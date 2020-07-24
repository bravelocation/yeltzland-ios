//
//  Tweet.swift
//  yeltzland
//
//  Created by John Pollard on 24/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

struct Tweet: Codable, Hashable {
    var fullText: String
    
    enum CodingKeys: String, CodingKey {
        case fullText = "full_text"
    }
}
