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
    
    let logoDim = CGFloat(40)
    
    static let tweetDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
        
    var body: some View {
        VStack {
            if self.tweetData.tweets.count == 0 {
                Text("Loading ...").padding()
            }
            
            List(self.tweetData.tweets, id: \.self) { tweet in
                VStack(alignment: .leading) {
                    self.tweetData.profilePic(tweet)
                        .resizable()
                        .scaledToFit()
                        .frame(width: self.logoDim, height: self.logoDim, alignment: .center)
                    Text(tweet.user.name)
                    Text("\(tweet.createdAt, formatter: Self.tweetDateFormat)")
                    Text(tweet.fullText)
                }.onTapGesture {
                    UIApplication.shared.open(URL(string: "https://twitter.com/\(tweet.user.screenName)/status/\(tweet.id)")!)
                }
            }
        }
        .onAppear {
            self.tweetData.refreshData()
        }
        .navigationBarTitle(Text("@\(tweetData.accountName)"))
        .navigationBarItems(trailing:
            Button(
                action: {
                    self.tweetData.refreshData()
                },
                label: {
                    Image(systemName: "arrow.counterclockwise").foregroundColor(Color.white)
                })
        )
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
