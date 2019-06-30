//
//  MakeToast.swift
//  yeltzland
//
//  Created by John Pollard on 01/10/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit

public class MakeToast {
    
    public static func show(_ controller:UIViewController, title:String, message:String) {
        let alert = UIAlertController(title:title, message:message, preferredStyle:.alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(defaultAction)

        controller.present(alert, animated: true, completion: nil)
    }
}
