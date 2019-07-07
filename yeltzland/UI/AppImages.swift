//
//  AppImages.swift
//  yeltzland
//
//  Created by John Pollard on 06/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation
import UIKit

enum AppImages {
    static var home: UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "house")
        }
        
        return UIImage(named: "home")
    }
    
    static var chevronLeft: UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "chevron.left")
        }
        
        return UIImage(named: "chevron-left")
    }
    
    static var chevronRight: UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "chevron.right")
        }
        
        return UIImage(named: "chevron-right")
    }
    
    static var safari: UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "safari")
        }
        
        return UIImage(named: "safari")
    }
    
    static var map: UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "map")
        }
        
        return UIImage(named: "map")
    }
    
    static var mapMarker: UIImage? {
        if #available(iOS 13, *) {
            return UIImage(systemName: "mappin.and.ellipse")
        }
        
        return UIImage(named: "map-marker")
    }
}
