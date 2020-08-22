//
//  LoadingIndicator.swift
//  Yeltzland
//
//  Created by John Pollard on 22/08/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation
import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

// See https://stackoverflow.com/questions/56496638/activity-indicator-in-swiftui
// Also for iOS14, can use a SwiftUI ProgressView() instead

@available(iOS 13.0, *)
struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
