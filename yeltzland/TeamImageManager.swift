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
        self.loadTeamImage(teamName: teamName, view: view, placeholder: "blank_team")
    }
    
    open func loadTeamImage(teamName:String, view:UIImageView, placeholder:String) {
        view.sd_setImage(with: self.teamImageUrl(teamName: teamName), placeholderImage:UIImage(imageLiteralResourceName: placeholder), completed: nil)
    }
    
    open func teamImageUrl(teamName:String) -> URL? {
        let imageUrl = String(format: "https://bravelocation.com/teamlogos/%@.png", self.makeTeamFileName(teamName))
        print("Loading team image: \(imageUrl)")
        
        return URL(string:imageUrl)
    }

    func makeTeamFileName(_ teamName:String) -> String {
        return teamName.replacingOccurrences(of: " ", with: "_").lowercased()
    }
}
