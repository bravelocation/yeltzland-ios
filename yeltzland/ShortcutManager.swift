//
//  ShortcutManager.swift
//  yeltzland
//
//  Created by John Pollard on 23/09/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import Foundation
import Intents

public class ShortcutManager {
    
    fileprivate static let sharedInstance = ShortcutManager()
    class var shared: ShortcutManager {
        get {
            return sharedInstance
        }
    }
    
    public func latestScoreIntent() -> LatestScoreIntent {
        let intent = LatestScoreIntent()
        intent.suggestedInvocationPhrase = "What's the latest score"
            
        return intent
    }
    
    public func nextGameIntent() -> NextGameIntent {
        let intent = NextGameIntent()
        intent.suggestedInvocationPhrase = "Who do we play next"
        
        return intent
    }
}
