//
//  IntentHandler.swift
//  LatestScoreIntent
//
//  Created by John Pollard on 22/09/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        
        if intent is LatestScoreIntent {
            return LatestScoreIntentHandler()
        }
        
        if intent is NextGameIntent {
            return NextGameIntentHandler()
        }
        
        fatalError("Unhandled intent type: \(intent)")
    }
}
