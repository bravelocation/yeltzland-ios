//
//  TeamImageManager.swift
//  yeltzland
//
//  Created by John Pollard on 12/06/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

open class TeamImageManager {
    fileprivate static let sharedInstance = TeamImageManager()
    class var instance:TeamImageManager {
        get {
            return sharedInstance
        }
    }
    
    open func loadTeamImage(teamName:String, view:UIImageView) {
        let imageUrl = String(format: "https://bravelocation.com/teamlogos/%@.png", self.makeTeamFileName(teamName))
        print("Loading team image: \(imageUrl)")
        
        view.sd_setImage(with: URL(string:imageUrl), placeholderImage:UIImage(imageLiteralResourceName: "blank_team"), completed: nil)
    }
    
    func makeTeamFileName(_ teamName:String) -> String {
        return teamName.replacingOccurrences(of: " ", with: "_").lowercased()
    }
}
