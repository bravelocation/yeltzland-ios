//
//  ResultsListHost.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 26/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI

class ResultsListHost: WKHostingController<GamesListView> {

    override var body: GamesListView {
        return GamesListView(gamesData: AllGamesData(useResults: true))
    }
}
