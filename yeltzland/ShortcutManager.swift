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
    
    @available(iOS 12.0, *)
    public func latestScoreIntent() -> LatestScoreIntent {
        let intent = LatestScoreIntent()
        intent.suggestedInvocationPhrase = "What's the latest score"
            
        return intent
    }
    
    @available(iOS 12.0, *)
    public func nextGameIntent() -> NextGameIntent {
        let intent = NextGameIntent()
        intent.suggestedInvocationPhrase = "Who do we play next"
        
        return intent
    }
    
    @available(iOS 12.0, *)
    public func donateAllShortcuts() {
        self.donateShortcut(intent: self.latestScoreIntent(), intentResponse: LatestScoreIntentResponse())
        self.donateShortcut(intent: self.nextGameIntent(), intentResponse: NextGameIntentResponse())
    }
    
    @available(iOS 12.0, *)
    private func donateShortcut(intent: INIntent, intentResponse: INIntentResponse) {
        let interaction = INInteraction(intent: intent, response: intentResponse)
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    print("Interaction donation failed: %@", error)
                }
            } else {
                print("Successfully donated interaction: %@", intent.intentDescription ?? "Unknown intent")
            }
        }
    }
}
