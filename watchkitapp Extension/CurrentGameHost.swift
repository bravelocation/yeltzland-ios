//
//  CurrentGameHost.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 25/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI

class CurrentGameHost: WKHostingController<CurrentGameView> {

    override var body: CurrentGameView {
        return CurrentGameView(data: CurrentGameData(
            fixtureManager: FixtureManager.shared,
            gameScoreManager: GameScoreManager.shared)
        )
    }
}
