//
//  TVOSTwitterView.swift
//  YeltzlandTVOS
//
//  Created by John Pollard on 06/12/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import SwiftUI

struct TVOSTwitterView: View {
    @EnvironmentObject var tweetData: TweetData
    
    var body: some View {

        List(self.tweetData.tweets, id: \.self) { tweet in
            TVOSTweetView(
                tweet: tweet.retweet ?? tweet
            ).padding([.top, .bottom], 8)
        }
        .onAppear {
            self.tweetData.refreshData()
        }
    }
}

struct TVOSTwitterView_Previews: PreviewProvider {
    static var previews: some View {
        let tweetData = TweetData(dataProvider: PreviewTwitterDataProvider(),
                                  accountName: "halesowentownfc")
        
        TVOSTwitterView().environmentObject(tweetData)
    }
}
