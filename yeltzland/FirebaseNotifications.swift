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

open class FirebaseNotifications : NSObject, MessagingDelegate {
    var topicName:String? = nil
    
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
        
        Messaging.messaging().delegate = self
    }
    
    func setupNotifications(_ forceSetup: Bool) {
        if (forceSetup || self.enabled) {
            let application = UIApplication.shared
            
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func register(_ deviceToken: Data) {
        // Register with Firebase Hub
        Messaging.messaging().apnsToken = deviceToken
        
        let fullTopic = self.topicName!
        
        if (self.enabled) {
            Messaging.messaging().subscribe(toTopic: fullTopic)
            print("Registered with Firebase: \(fullTopic)")
        } else {
            Messaging.messaging().unsubscribe(fromTopic: fullTopic)
            print("Unregistered with firebase \(fullTopic)")
        }
    }
    
    // MARK: - MessagingDelegate    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
}
