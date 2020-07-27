//
//  TweetBodyView.swift
//  yeltzland
//
//  Created by John Pollard on 25/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0.0, *)
struct TweetBodyView: View {
    
    var textParts: [TweetPart]
    
    var body: some View {
        var combined: Text = Text("")
        
        for part in self.textParts {
            var nextText = Text(part.text)
            if (part.highlight) {
                nextText = nextText.foregroundColor(Color("blue-tint"))
            }
            
            combined = combined + nextText
        }
        
        return combined
    }
}

@available(iOS 13.0.0, *)
struct TweetBodyView_Previews: PreviewProvider {
    static var previews: some View {
        TweetBodyView(
        textParts: [
                TweetPart(text: "1 ", highlight: false),
                TweetPart(text: "2", highlight: true),
                TweetPart(text: " 3", highlight: false)
            ]
        )
    }
}
