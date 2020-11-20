//
//  TwitterTimelineView.swift
//  yeltzland
//
//  Created by John Pollard on 24/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0.0, *)
struct TwitterTimelineView: View {
    @EnvironmentObject var tweetData: TweetData
        
    var body: some View {
        ZStack {
            List(self.tweetData.tweets, id: \.self) { tweet in
                TweetView(
                    tweet: tweet.retweet ?? tweet
                ).padding([.top, .bottom], 8)
            }.onAppear {
                UITableView.appearance().separatorStyle = .none
            }
            
            if self.tweetData.state == .isLoading {
                ActivityIndicator(
                    isAnimating: .constant(true),
                    style: .large,
                    color: UIColor(named: "blue-tint"))
            }
            
        }
        .frame(maxWidth: 800)
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
                    Image(systemName: "arrow.clockwise").foregroundColor(Color.white)
                })
                .buttonStyle(PlainButtonStyle())
                .padding()

        )
    }
}

@available(iOS 13.0.0, *)
struct TwitterTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TwitterTimelineView()
            .environmentObject(
                TweetData(dataProvider: PreviewTwitterDataProvider(),
                          accountName: "halesowentownfc"))
    }
}
