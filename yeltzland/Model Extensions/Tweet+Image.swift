//
//  Tweet+Image.swift
//  yeltzland
//
//  Created by John Pollard on 26/07/2020.
//  Copyright © 2020 John Pollard. All rights reserved.
//

import Foundation

extension Media {
    var smallImageUrl: String? {
        // Parse off file type
        if let fullUrl = URL(string: self.mediaUrl) {
            let pathDir = fullUrl.deletingLastPathComponent().absoluteString
            let fileNameWithoutExtension = fullUrl.deletingPathExtension().lastPathComponent
            let fileExtension = fullUrl.pathExtension
            
            if (fileExtension == "jpg" || fileExtension == "png") {
                return "\(pathDir)\(fileNameWithoutExtension)?format=\(fileExtension)&name=small"
            }
        }
        
        return nil
    }
}
