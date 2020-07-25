//
//  TweetView.swift
//  yeltzland
//
//  Created by John Pollard on 25/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct TweetView: View {
    
    var tweet: DisplayTweet
    var profilePic: Image
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                self.profilePic
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32, alignment: .center)
                .cornerRadius(4.0)
                
                if (tweet.isRetweet) {
                    Image(systemName: "arrow.right.arrow.left.square")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(self.tweet.user.name)
                            .font(.callout)
                        Text("@\(self.tweet.user.screenName)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                    
                    Text(self.tweet.timeAgo)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(nil)
                }
                
                TweetBodyView(textParts: self.tweet.textParts)
                    .padding(.top, 8)
            }
        }
        .onTapGesture {
            UIApplication.shared.open(URL(string: "https://twitter.com/\(self.tweet.user.screenName)/status/\(self.tweet.id)")!)
        }
    }
}

@available(iOS 13.0.0, *)
struct TweetView_Previews: PreviewProvider {
    static let testTweet = Tweet(id: "1286327578949832704",
          fullText: "ICYMI: Copies of YELTZMEN can be pre-ordered up until 5pm on Saturday 25th July at the reduced price of £12.99 https://t.co/jtzAOR5yjJ #UpTheYeltz https://t.co/R1xNPbQAvM",
          user: User(name: "Halesowen Town FC",
                     screenName: "halesowentownfc",
                     profileImageUrl: "https://pbs.twimg.com/profile_images/1195108198715400192/TMrPMD8B_normal.jpg"),
          createdAt: Date(),
          entities: Entities(
                        hashtags: [],
                        urls: [],
                        userMentions: [],
                        symbols: []
                    )
    )
    
    static var previews: some View {
        TweetView(tweet: TweetView_Previews.testTweet, profilePic: Image(systemName: "person.circle"))
    }
}
