//
//  TwitterTimelineView.swift
//  yeltzland
//
//  Created by John Pollard on 24/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct TwitterTimelineView: View {
    @ObservedObject var tweetData: TweetData
        
    var body: some View {
        VStack {
            if self.tweetData.tweets.count == 0 {
                Text("Loading ...").padding()
            }
            
            List(self.tweetData.tweets, id: \.self) { tweet in
                HStack {
                    Text(tweet.fullText)
                }.onTapGesture {
                    UIApplication.shared.open(URL(string: "https://twitter.com/\(self.tweetData.accountName)/status/\(tweet.id)")!)
                }
            }
        }
        .onAppear {
            self.tweetData.refreshData()
        }
        .navigationBarTitle(Text("@\(tweetData.accountName)"))
    }
}

@available(iOS 13.0.0, *)
struct TwitterTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TwitterTimelineView(tweetData: TweetData(
            dataProvider: PreviewTwitterDataProvider(),
            accountName: "halesowentownfc"))
    }
}
