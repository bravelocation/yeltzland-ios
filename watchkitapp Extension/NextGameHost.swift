//
//  NextGameHost.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI

class NextGameHost: WKHostingController<NextGameView> {

    override var body: NextGameView {
        return NextGameView()
    }
}

