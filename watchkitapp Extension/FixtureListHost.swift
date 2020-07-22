//
//  FixtureListHost.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI

class FixtureListHost: WKHostingController<FixturesListView> {

    override var body: FixturesListView {
        return FixturesListView(gamesData: AllGamesData(useResults: false))
    }
}
