//
//  FirebaseNotifications.swift
//  yeltzland
//
//  Created by John Pollard on 25/11/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

public class FirebaseNotifications: NSObject, MessagingDelegate {
    var topicName: String? = nil
    
    var enabled: Bool {
        get {
            return GameSettings.shared.gameTimeTweetsEnabled
        }
        set(newValue) {
            // If changed, set the value
            if (newValue != self.enabled) {
                GameSettings.shared.gameTimeTweetsEnabled = newValue
            }
            
            // If setting to true, setup notifications
            if newValue {
                self.setupNotifications(true)
            }
            
            // Setup subscriptions
            self.subscribe(newValue)
        }
    }
    
    override init() {
        super.init()
        
        self.topicName = "gametimealerts"
        #if DEBUG
            self.topicName = "testtag"
        #endif

        Messaging.messaging().delegate = self
    }
    
    func setupNotifications(_ forceSetup: Bool) {
        if (forceSetup || self.enabled) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
                if (granted) {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
    func register(_ deviceToken: Data) {
        // Register with Firebase Hub
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func subscribe(_ subscribe: Bool) {
        if let fullTopic = self.topicName {
            if subscribe {
                Messaging.messaging().subscribe(toTopic: fullTopic)
                print("Registered with Firebase: \(fullTopic)")
            } else {
                Messaging.messaging().unsubscribe(fromTopic: fullTopic)
                print("Unregistered with firebase \(fullTopic)")
            }
        }
    }
    
    // MARK: - MessagingDelegate    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "Missing")")
        
        self.subscribe(self.enabled)
    }
}
