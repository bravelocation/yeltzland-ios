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
            return GameSettings.instance.gameTimeTweetsEnabled
        }
        set(newValue) {
            // If changed, set the value and re-register
            let currentValue = self.enabled
            
            if (newValue != currentValue) {
                GameSettings.instance.gameTimeTweetsEnabled = newValue
                
                self.setupNotifications(true)
            }
        }
    }
    
    override init() {
        super.init()
        
        self.topicName = "gametimealerts"
        #if DEBUG
            self.topicName = "testtag"
        #endif
    }
    
    // Must be done after FirebaseApp.configure() according to https://github.com/firebase/firebase-ios-sdk/issues/2240
    func setupMessagingDelegate() {
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
    
    // MARK: - MessagingDelegate    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        if let fullTopic = self.topicName {

            if self.enabled {
                Messaging.messaging().subscribe(toTopic: fullTopic)
                print("Registered with Firebase: \(fullTopic)")
            } else {
                Messaging.messaging().unsubscribe(fromTopic: fullTopic)
                print("Unregistered with firebase \(fullTopic)")
            }
        }
    }
}
