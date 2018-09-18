//
//  TeamImageManager.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 02/07/2018.
//  Copyright © 2018 John Pollard. All rights reserved.
//

import Foundation
import WatchKit
import SDWebImage

public class TeamImageManager {
    fileprivate static let sharedInstance = TeamImageManager()
    class var instance:TeamImageManager {
        get {
            return sharedInstance
        }
    }
    
    public func loadTeamImage(teamName:String, view:WKInterfaceImage) {
        let imageUrl = String(format: "https://bravelocation.com/teamlogos/%@.png", self.makeTeamFileName(teamName))
        print("Loading team image: \(imageUrl)")
        
        view.sd_setImage(with: URL(string:imageUrl), placeholderImage:UIImage(imageLiteralResourceName: "blank_team"), completed: nil)
    }
    
    func makeTeamFileName(_ teamName:String) -> String {
        let teamFileName = teamName.replacingOccurrences(of: " ", with: "_").lowercased()
        
        // Do we have a bracket in the name
        let bracketPos = teamFileName.index(of: "(")
        if bracketPos == nil {
            return teamFileName
        } else {
            let beforeBracket = teamFileName.split(separator: "(", maxSplits: 1, omittingEmptySubsequences: true)[0]
            return beforeBracket.trimmingCharacters(in: CharacterSet(charactersIn: " _"))
        }
    }
}
