//
//  Tweet_Text.swift
//  yeltzland
//
//  Created by John Pollard on 25/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

struct TweetPart {
    var text: String
    var highlight: Bool
}

extension DisplayTweet {
    var textParts: [TweetPart] {
        var entityParts: [TweetEntity] = []
        
        entityParts.append(contentsOf: self.entities.hashtags)
        entityParts.append(contentsOf: self.entities.urls)
        entityParts.append(contentsOf: self.entities.userMentions)
        entityParts.append(contentsOf: self.entities.symbols)
        if let media = self.entities.media {
            entityParts.append(contentsOf: media)
        }

        entityParts.sort { (a, b) -> Bool in
            return a.indices.first! < b.indices.first!
        }
        
        var textParts: [TweetPart] = []
        var currentPoint: Int = 0
        let endPoint = self.fullText.count - 1
        
        for entityPart in entityParts {
            let entityStart = entityPart.indices[0]
            let entityEnd = entityPart.indices[1]
            
            if currentPoint <= entityStart {
                // Add the tweet text up to the entity
                let textUpToEntityStart = String(self.fullText.dropFirst(currentPoint).prefix(entityStart - currentPoint))
                textParts.append(TweetPart(text: textUpToEntityStart, highlight: false))
                
                // Add the display text of the entity
                textParts.append(TweetPart(text: entityPart.displayText, highlight: true))
                
                // Move the current point past the entity
                currentPoint = entityEnd
            }
        }
        
        // Finally add any remaining text
        if (currentPoint < endPoint) {
            let textUpToEntityStart = String(self.fullText.dropFirst(currentPoint).prefix(endPoint - currentPoint))
            textParts.append(TweetPart(text: textUpToEntityStart, highlight: false))
        }
        
        return textParts
    }
}
