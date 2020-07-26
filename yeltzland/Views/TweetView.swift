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
                Button(action: {
                    self.openUserTwitterPage()
                }) {
                    self.profilePic
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32, alignment: .center)
                    .cornerRadius(4.0)
                }
                .buttonStyle(PlainButtonStyle())
                
                if (tweet.isRetweet) {
                    Image(systemName: "arrow.right.arrow.left")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(self.tweet.user.name)
                            .font(.headline)
                        Text("@\(self.tweet.user.screenName)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        self.openUserTwitterPage()
                    }

                    Spacer()
                    
                    Text(self.tweet.timeAgo)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(nil)
                }
                
                TweetBodyView(textParts: self.tweet.textParts)
                    .padding([.top, .bottom], 8)
                    .onTapGesture {
                        self.openTweetPage()
                    }
            }
        }
    }
    
    func openUserTwitterPage() {
        UIApplication.shared.open(URL(string: "https://twitter.com/\(self.tweet.user.screenName)")!)
    }
    
    func openTweetPage() {
        UIApplication.shared.open(URL(string: "https://twitter.com/\(self.tweet.user.screenName)/status/\(self.tweet.id)")!)
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
                        hashtags: [Hashtag(text: "UpTheYeltz", indices: [135, 146])],
                        urls: [TweetUrl(url: "https://t.co/jtzAOR5yjJ",
                                        displayUrl: "ht-fc.co.uk/yeltzmen-book-\\u2026",
                                        expandedUrl: "https://www.ht-fc.co.uk/yeltzmen-book-launch",
                                        indices: [111, 134])],
                        userMentions: [],
                        symbols: [],
                        media: [
                            Media(id: "1286327220433231880",
                                  displayUrl: "pic.twitter.com/R1xNPbQAvM",
                                  expandedUrl: "https://twitter.com/halesowentownfc/status/1286327578949832704/photo/1",
                                  mediaUrl: "https://pbs.twimg.com/media/Ednzyq7WoAghlfJ.jpg",
                                  sizes: MediaSizes(
                                    thumb: MediaSize(height: 150, resize: "crop", width: 150),
                                    large: MediaSize(height: 1598, resize: "fit", width: 1600),
                                    medium: MediaSize(height: 1199, resize: "fit", width: 1200),
                                    small: MediaSize(height: 679, resize: "fit", width: 680)),
                                  indices: [147, 170])
                        ]
                    )
    )
    
    static var previews: some View {
        TweetView(tweet: TweetView_Previews.testTweet, profilePic: Image(systemName: "person.circle"))
    }
}
