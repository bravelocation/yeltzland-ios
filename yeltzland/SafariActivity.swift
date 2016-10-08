//
//  SafariActivity.swift
//  yeltzland
//
//  Created by John Pollard on 14/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class SafariActivity: UIActivity {
    
    var currentUrl: URL?
    
    init(currentUrl: URL?) {
        self.currentUrl = currentUrl
        super.init()
    }
    
    override var activityType: UIActivityType? {
        return UIActivityType("com.bravelocation.yeltzland.safari")
    }
    
    override var activityImage: UIImage
    {
        return UIImage(icon: FAType.faSafari, size: CGSize(width: 66, height: 66), textColor: UIColor.blue, backgroundColor: UIColor.clear)
    }
    
    override var activityTitle : String
    {
        return "Open in Safari";
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // nothing to prepare
    }
    
    override class var activityCategory : UIActivityCategory{
        return UIActivityCategory.action
    }
    
    func canOpenChrome() -> Bool {
        if (self.currentUrl == nil) {
            return false;
        }
        
        return UIApplication.shared.canOpenURL(self.currentUrl!)
    }
    
    override func perform() {
        print("Perform activity")
        
        if (self.currentUrl != nil) {
            if(UIApplication.shared.canOpenURL(self.currentUrl!)){
                UIApplication.shared.openURL(self.currentUrl!)
            }
        }
    }
}
