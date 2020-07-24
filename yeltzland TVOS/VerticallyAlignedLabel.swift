//
//  VerticallyAlignedLabel.swift
//  yeltzlandTVOS
//
//  Created by John Pollard on 19/12/2017.
//  Copyright © 2017 John Pollard. All rights reserved.
//

import Foundation
import UIKit

class VerticallyAlignedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        guard let labelText = text else {  return super.drawText(in: rect) }
        
        let attributedText = NSAttributedString(string: labelText, attributes: [NSAttributedString.Key.font: font])
        var newRect = rect
        newRect.size.height = attributedText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, context: nil).size.height
        
        if numberOfLines != 0 {
            newRect.size.height = min(newRect.size.height, CGFloat(numberOfLines) * font.lineHeight)
        }
        
        super.drawText(in: newRect)
    }
    
}
