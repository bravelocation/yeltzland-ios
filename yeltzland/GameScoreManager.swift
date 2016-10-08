//
//  GameScoreManager.swift
//  yeltzland
//
//  Created by John Pollard on 28/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

open class GameScoreManager {
    open static let GameScoreNotification:String = "YLZGameScoreNotification"
    
    fileprivate var matchDate:Date? = nil
    fileprivate var yeltzScore:Int = 0
    fileprivate var opponentScore:Int = 0
    
    fileprivate static let sharedInstance = GameScoreManager()
    class var instance:GameScoreManager {
        get {
            return sharedInstance
        }
    }
    
    open var MatchDate: Date? {
        return self.matchDate
    }
    
    open var YeltzScore: Int {
        return self.yeltzScore
    }
    
    open var OpponentScore: Int {
        return self.opponentScore
    }
    
    init() {
        // Setup local data
        self.moveSingleBundleFileToAppDirectory("gamescore", fileType: "json")
        
        let data:Data? = try? Data.init(contentsOf: URL(fileURLWithPath: self.appDirectoryFilePath("gamescore", fileType: "json")))
        
        if (data == nil) {
            print("Couldn't load game score from cache")
            return
        }
        
        do {
            print("Loading game score from cache ...")
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String : AnyObject]
            
            if (json == nil) {
                print("Couldn't parse game score from cache")
                return
            }
            
            self.parseGameScoreJson(json!)
            print("Loaded game score from cache")
        } catch {
            print("Error loading game score from cache ...")
            print(error)
        }
    }
    
    open func getLatestGameScore() {
        print("Preparing to fetch game score ...")
        
        let dataUrl = URL(string: "https://bravelocation.com/automation/feeds/gamescore.json")!
        let urlRequest = URLRequest(url: dataUrl, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (serverData, response, error) -> Void in
            if (error != nil) {
                print("Error downloading game score from server: \(error.debugDescription)")
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                if (serverData == nil) {
                    print("Couldn't download game score from server")
                    return
                }
                
                self.loadGameScoreData(serverData);
            } else {
                print("Error response from server: \(statusCode)")
            }
        }) 
        
        task.resume()
    }
    
    open func loadGameScoreData(_ data:Data?) {
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String : AnyObject]
            
            if (json == nil) {
                print("Couldn't parse game score from server")
                return
            }
            
            self.parseGameScoreJson(json!)
            
            // Fetch went OK, so write to local file for next startup
            if (self.MatchDate != nil) {
                print("Saving server game score to cache")
                
                try data?.write(to: URL(fileURLWithPath: self.appDirectoryFilePath("gamescore", fileType: "json")), options: .atomic)
            }
            
            print("Loaded game score from server")
            
            // Post notification message
            NotificationCenter.default.post(name: Notification.Name(rawValue: GameScoreManager.GameScoreNotification), object: nil)
        } catch {
            print("Error loading game score from server ...")
            print(error)
        }
    }
    
    fileprivate func parseGameScoreJson(_ json:[String:AnyObject]) {
        // Clear settings
        self.matchDate = nil
        self.yeltzScore = 0
        self.opponentScore = 0
        
        if let currentMatch = json["match"] {
            if let fixture = Fixture(fromJson: currentMatch as! [String : AnyObject]) {
                self.matchDate = fixture.fixtureDate as Date
            }
        }

        if let parsedYeltzScore = json["yeltzScore"] as? String {
            self.yeltzScore = Int(parsedYeltzScore)!
        }
        
        if let parsedOpponentScore = json["opponentScore"] as? String {
            self.opponentScore = Int(parsedOpponentScore)!
        }
    }
    
    fileprivate func moveSingleBundleFileToAppDirectory(_ fileName:String, fileType:String) {
        if (self.checkAppDirectoryExists(fileName, fileType:fileType))
        {
            // If file already exists, return
            print("GameScore file exists, don't copy from bundle")
            return
        }
        
        let fileManager = FileManager.default
        let bundlePath = Bundle.main.path(forResource: fileName, ofType: fileType)!
        if fileManager.fileExists(atPath: bundlePath) == false {
            // No bundle file exists
            print("Missing bundle file")
            return
        }
        
        // Finally, copy the bundle file
        do {
            try fileManager.copyItem(atPath: bundlePath, toPath: self.appDirectoryFilePath(fileName, fileType: fileType))
        }
        catch {
            return
        }
    }
    
    fileprivate func appDirectoryFilePath(_ fileName:String, fileType:String) -> String {
        let appDirectoryPath = self.applicationDirectory()?.path
        let filePath = String.init(format: "%@.%@", fileName, fileType)
        return ((appDirectoryPath)! + filePath)
    }
    
    fileprivate func checkAppDirectoryExists(_ fileName:String, fileType:String) -> Bool {
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: self.appDirectoryFilePath(fileName, fileType:fileType))
    }
    
    fileprivate func applicationDirectory() -> URL? {
        let bundleId = Bundle.main.bundleIdentifier
        let fileManager = FileManager.default
        var dirPath: URL? = nil
        
        // Find the application support directory in the home directory.
        let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        if (appSupportDir.count > 0) {
            // Append the bundle ID to the URL for the Application Support directory
            dirPath = appSupportDir[0].appendingPathComponent(bundleId!, isDirectory: true)
            
            do {
                try fileManager.createDirectory(at: dirPath!, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return nil
            }
        }
        
        return dirPath
    }
    
}
