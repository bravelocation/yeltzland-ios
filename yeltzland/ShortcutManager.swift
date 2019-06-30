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
    class var instance: ShortcutManager {
        get {
            return sharedInstance
        }
    }
    
    @available(iOS 12.0, *)
    public func latestScoreIntent() -> LatestScoreIntent {
        let intent = LatestScoreIntent()
        intent.suggestedInvocationPhrase = "What's the latest score"
            
        return intent
    }
    
    @available(iOS 12.0, *)
    public func donateAllShortcuts() {
        let intentResponse = LatestScoreIntentResponse()
        let intent = self.latestScoreIntent()
        
        let interaction = INInteraction(intent: intent, response: intentResponse)
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    print("Interaction donation failed: %@", error)
                }
            } else {
                print("Successfully donated interaction")
            }
        }
    }
}
