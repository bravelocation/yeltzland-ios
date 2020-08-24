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
struct PullToRefreshTwitterTimelineView<Content: View, ViewModel: RefreshableViewModel>: UIViewRepresentable {
    var width: CGFloat
    var height: CGFloat
    
    let viewModel: ViewModel
    let content: () -> Content

    init(width: CGFloat, height: CGFloat, viewModel: ViewModel, @ViewBuilder content: @escaping () -> Content) {
        self.width = width
        self.height = height
        self.viewModel = viewModel
        self.content = content
    }

    func makeUIView(context: Context) -> UIScrollView {
        let control = UIScrollView()
        control.refreshControl = UIRefreshControl()
        control.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)

        let childView = UIHostingController(rootView: content())
        childView.view.frame = CGRect(x: 0, y: 0, width: width, height: height)

        control.addSubview(childView.view)
        return control
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject {
        var control: PullToRefreshTwitterTimelineView<Content, ViewModel>
        var viewModel: ViewModel

        init(_ control: PullToRefreshTwitterTimelineView, viewModel: ViewModel) {
            self.control = control
            self.viewModel = viewModel
        }

        @objc func handleRefreshControl(sender: UIRefreshControl) {
            sender.endRefreshing()
            viewModel.refreshData()
        }
    }
}
