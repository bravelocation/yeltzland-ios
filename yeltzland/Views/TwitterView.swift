//
//  TwitterView.swift
//  Yeltzland
//
//  Created by John Pollard on 22/08/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct TwitterView: View {
    @EnvironmentObject var tweetData: TweetData
    
    var body: some View {
        GeometryReader { geometry in
            PullToRefreshTwitterTimelineView(width: geometry.size.width, height: geometry.size.height, tweetData: self.tweetData)
        }
    }
}

@available(iOS 13.0.0, *)
struct TwitterView_Previews: PreviewProvider {
    static var previews: some View {
        TwitterView()
    }
}
