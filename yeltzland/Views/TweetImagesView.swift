//
//  TweetImagesView.swift
//  yeltzland
//
//  Created by John Pollard on 26/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

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
                .frame(maxWidth: 500)
                .onTapGesture {
                    if let linkUrl = media.linkUrl {
                        UIApplication.shared.open(URL(string: linkUrl)!)
                    }
                }
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
