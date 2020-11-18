//
//  GameTimeTweetsViewController.swift
//  Yeltzland
//
//  Created by John Pollard on 01/11/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import UIKit

class GameTimeTweetsViewController: UIViewController {
    
    let firebaseNotifications = FirebaseNotifications()

    @IBOutlet weak var enableButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Game Time Tweet Notifications"
        
        self.enableButton.backgroundColor = .clear
        self.enableButton.layer.cornerRadius = self.enableButton.frame.size.height / 2.0
        self.enableButton.layer.borderWidth = 1
        self.enableButton.layer.borderColor = UIColor(named: "blue-tint")?.cgColor

        self.setButtonText()
    }

    @IBAction func enableButtonTouchUp(_ sender: Any) {
        self.firebaseNotifications.enabled.toggle()
        self.setButtonText()
    }
    
    private func setButtonText() {
        self.enableButton.setTitle(self.firebaseNotifications.enabled ? "Turn Off" : "Turn On", for: .normal)
    }
}
