//
//  MakeToast.swift
//  yeltzland
//
//  Created by John Pollard on 01/10/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit

open class MakeToast {
    
    open static func Show(_ view:UIView, message:String, delay: Double) {
        // Make label with rounded corners tto show
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = AppColors.ToastBackgroundColor
        toastLabel.textColor = AppColors.ToastTextColor
        toastLabel.textAlignment = NSTextAlignment.center;
        toastLabel.text = message
        toastLabel.font = UIFont(name: AppColors.AppFontName, size:AppColors.ToastTextSize)!
        
        toastLabel.adjustsFontSizeToFitWidth = true
        toastLabel.allowsDefaultTighteningForTruncation = true
        toastLabel.minimumScaleFactor = 0.8
        
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        // Add the label to the view
        view.addSubview(toastLabel)

        // Fade the label out
        UIView.animate(withDuration: 1.0, delay: delay, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
            }, completion: {(value: Bool) in
                // Remove the label from the view when done
                toastLabel.removeFromSuperview();
            }
        )
    }
    
}
