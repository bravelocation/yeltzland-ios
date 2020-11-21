//
//  Tweet_Text.swift
//  yeltzland
//
//  Created by John Pollard on 25/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import UIKit

struct TweetPart {
    var text: String
    var linkUrl: String?
    
    var highlight: Bool {
        return linkUrl != nil
    }
}

extension DisplayTweet {
    var textParts: [TweetPart] {
        var entityParts: [TweetEntity] = []
        
        entityParts.append(contentsOf: self.entities.hashtags)
        entityParts.append(contentsOf: self.entities.urls)
        entityParts.append(contentsOf: self.entities.userMentions)
        entityParts.append(contentsOf: self.entities.symbols)
        if let media = self.extendedEntities?.media {
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
                let textUpToEntityStart = String(self.fullText.dropFirstUnicode(currentPoint).prefixUnicode(entityStart - currentPoint))
                textParts.append(TweetPart(text: textUpToEntityStart, linkUrl: nil))
                
                // Add the display text of the entity
                textParts.append(TweetPart(text: entityPart.displayText, linkUrl: entityPart.linkUrl))
                
                // Move the current point past the entity
                currentPoint = entityEnd
            }
        }
        
        // Finally add any remaining text
        if (currentPoint < endPoint) {
            let textUpToEntityStart = String(self.fullText.dropFirstUnicode(currentPoint).prefixUnicode(endPoint - currentPoint + 1))
            textParts.append(TweetPart(text: textUpToEntityStart, linkUrl: nil))
        }
        
        return textParts
    }
}

extension DisplayTweet {
    var attributedString: NSAttributedString {
        var entityParts: [TweetEntity] = []
        
        entityParts.append(contentsOf: self.entities.hashtags)
        entityParts.append(contentsOf: self.entities.urls)
        entityParts.append(contentsOf: self.entities.userMentions)
        entityParts.append(contentsOf: self.entities.symbols)
        if let media = self.extendedEntities?.media {
            entityParts.append(contentsOf: media)
        }

        entityParts.sort { (a, b) -> Bool in
            return a.indices.first! < b.indices.first!
        }
        
        let linkAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.blue]

        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        
        var currentPoint: Int = 0
        let endPoint = self.fullText.count - 1
        
        for entityPart in entityParts {
            let entityStart = entityPart.indices[0]
            let entityEnd = entityPart.indices[1]
            
            if currentPoint <= entityStart {
                // Add the tweet text up to the entity
                let textUpToEntityStart = String(self.fullText.dropFirstUnicode(currentPoint).prefixUnicode(entityStart - currentPoint))
                
                let textPartAttributedString = NSAttributedString(string: textUpToEntityStart)
                attributedString.append(textPartAttributedString)
                
                // Add the display text of the entity
                let displayText = NSMutableAttributedString(string: entityPart.displayText)
                let fullRange = NSRange(location: 0, length: entityPart.displayText.count)
                displayText.addAttributes(linkAttributes, range: fullRange)
                
                if let linkUrl = entityPart.linkUrl {
                    displayText.addAttribute(.link, value: linkUrl, range: fullRange)
                }
                
                attributedString.append(displayText)
                
                // Move the current point past the entity
                currentPoint = entityEnd
            }
        }
        
        // Finally add any remaining text
        if (currentPoint < endPoint) {
            let textUpToEntityStart = String(self.fullText.dropFirstUnicode(currentPoint).prefixUnicode(endPoint - currentPoint + 1))
            
            let textPartAttributedString = NSAttributedString(string: textUpToEntityStart)
            attributedString.append(textPartAttributedString)
        }
        
        return attributedString
    }
}

extension String {
    func dropFirstUnicode (_ count: Int) -> Substring {
        let range = self.unicodeScalars.index(self.unicodeScalars.startIndex, offsetBy: count)..<self.unicodeScalars.endIndex
        
        return Substring(self.unicodeScalars[range])
    }
}

extension Substring {
    func prefixUnicode (_ count: Int) -> Substring {
        let range = self.unicodeScalars.index(self.unicodeScalars.startIndex, offsetBy: 0)..<self.unicodeScalars.index(self.unicodeScalars.startIndex, offsetBy: count)
        
        return Substring(self.unicodeScalars[range])
    }
}

extension String {
    func decodeEntities() -> String {
        return self.replacingOccurrences(of: "&amp;", with: "&")
    }
}
