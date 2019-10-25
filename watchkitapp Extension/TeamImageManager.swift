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
    class var shared: TeamImageManager {
        get {
            return sharedInstance
        }
    }
    
    public func teamURL(_ teamName: String) -> URL? {
        let imageUrl = String(format: "https://bravelocation.com/teamlogos/%@.png", self.makeTeamFileName(teamName))
        
        return URL(string: imageUrl)
    }
    
    public func loadTeamImage(teamName: String, view: WKInterfaceImage) {
        view.sd_setImage(with: self.teamURL(teamName), placeholderImage: UIImage(imageLiteralResourceName: "blank_team"), completed: nil)
    }
    
    public func loadTeamImage(teamName: String, completion: @escaping (UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(with: self.teamURL(teamName),
                                           options: .continueInBackground,
                                           progress: nil) { image, _, _, _, _, _  in
                                            completion(image)
        }
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
