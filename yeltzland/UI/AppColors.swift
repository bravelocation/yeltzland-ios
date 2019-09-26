//
//  AppColors.swift
//  yeltzland
//
//  Created by John Pollard on 05/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation
import UIKit

// Based on https://noahgilmore.com/blog/dark-mode-uicolor-compatibility/
// Can remove once app support is above iOS 12!
enum AppColors {
    static var label: UIColor {
        if #available(iOS 13, *) {
            return .label
        }
        return UIColor.black
    }
    
    static var secondaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        }
        return UIColor.gray
    }
    
    static var systemBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        }
        return UIColor.white
    }
    
    static var red: UIColor {
        if #available(iOS 13, *) {
            return .systemRed
        }
        return UIColor.red
    }
}
