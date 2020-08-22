//
//  PullToRefreshScrollView.swift
//  Yeltzland
//
//  Created by John Pollard on 22/08/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

// Adadpted from code in https://stackoverflow.com/questions/61371525/swiftui-generic-pull-to-refresh-view/61371933#61371933

import Foundation
import UIKit
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0, *)
struct PullToRefreshTwitterTimelineView: UIViewRepresentable {
    var width: CGFloat
    var height: CGFloat
    var tweetData: TweetData

    init(width: CGFloat, height: CGFloat, tweetData: TweetData) {
        self.width = width
        self.height = height
        self.tweetData = tweetData
    }

    func makeUIView(context: Context) -> UIScrollView {
        let control = UIScrollView()
        control.refreshControl = UIRefreshControl()
        control.tintColor = UIColor(named: "blue-tint")!
        control.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)

        let childView = UIHostingController(rootView: TwitterTimelineView().environmentObject(self.tweetData))
        childView.view.frame = CGRect(x: 0, y: 0, width: width, height: height)

        control.addSubview(childView.view)
        return control
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, tweetData: self.tweetData)
    }

    class Coordinator: NSObject {
        var control: PullToRefreshTwitterTimelineView
        var tweetData: TweetData

        init(_ control: PullToRefreshTwitterTimelineView, tweetData: TweetData) {
            self.control = control
            self.tweetData = tweetData
        }

        @objc func handleRefreshControl(sender: UIRefreshControl) {
            sender.endRefreshing()
            self.tweetData.refreshData()
        }
    }
}
