//
//  ResultsListHost.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 26/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation
import SwiftUI

class ResultsListHost: WKHostingController<ResultsListView> {

    override var body: ResultsListView {
        return ResultsListView(gamesData: AllGamesData(useResults: true))
    }
}
