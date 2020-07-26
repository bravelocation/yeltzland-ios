//
//  TweetImagesView.swift
//  yeltzland
//
//  Created by John Pollard on 26/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI

@available(iOS 13.0.0, *)
struct TweetImagesView: View {
    @EnvironmentObject var tweetData: TweetData
    
    var mediaParts: [Media]
    
    var body: some View {
        VStack {
            ForEach(mediaParts, id: \.self) { media in
               self.tweetData.tweetImage(media)
                .resizable()
                .scaledToFit()
                .cornerRadius(16.0)
            }
        }
    }
}

@available(iOS 13.0.0, *)
struct TweetImagesView_Previews: PreviewProvider {
    static var previews: some View {
        TweetImagesView(
        mediaParts: []
        )
    }
}
