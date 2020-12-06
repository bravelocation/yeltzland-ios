//
//  TVOSTweetImageView.swift
//  YeltzlandTVOS
//
//  Created by John Pollard on 06/12/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

struct TVOSTweetImagesView: View {
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
            }
        }
    }
}

struct TVOSTweetImagesView_Previews: PreviewProvider {
    static var previews: some View {
        TVOSTweetImagesView(
            mediaParts: []
        )
    }
}
