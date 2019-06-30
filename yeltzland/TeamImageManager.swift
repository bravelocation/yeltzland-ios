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

public class TeamImageManager {
    fileprivate static let sharedInstance = TeamImageManager()
    class var instance: TeamImageManager {
        get {
            return sharedInstance
        }
    }
    
    public func loadTeamImage(teamName: String, view: UIImageView) {
        self.loadTeamImage(teamName: teamName, view: view, placeholder: "blank_team")
    }
    
    public func loadTeamImage(teamName: String, view: UIImageView, placeholder: String) {
        view.sd_setImage(with: self.teamImageUrl(teamName: teamName), placeholderImage: UIImage(imageLiteralResourceName: placeholder), completed: nil)
    }
    
    public func teamImageUrl(teamName: String) -> URL? {
        let imageUrl = String(format: "https://bravelocation.com/teamlogos/%@.png", self.makeTeamFileName(teamName))
        print("Loading team image: \(imageUrl)")
        
        return URL(string: imageUrl)
    }

    func makeTeamFileName(_ teamName: String) -> String {
        let teamFileName = teamName.replacingOccurrences(of: " ", with: "_").lowercased()
        
        // Do we have a bracket in the name
        let bracketPos = teamFileName.firstIndex(of: "(")
        if bracketPos == nil {
            return teamFileName
        } else {
            let beforeBracket = teamFileName.split(separator: "(", maxSplits: 1, omittingEmptySubsequences: true)[0]
            return beforeBracket.trimmingCharacters(in: CharacterSet(charactersIn: " _"))
        }
    }
}
