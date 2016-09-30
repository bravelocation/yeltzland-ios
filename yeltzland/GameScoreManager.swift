//
//  GameScoreManager.swift
//  yeltzland
//
//  Created by John Pollard on 28/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

public class GameScoreManager {
    public static let GameScoreNotification:String = "YLZGameScoreNotification"
    
    private var matchDate:NSDate? = nil
    private var yeltzScore:Int = 0
    private var opponentScore:Int = 0
    
    private static let sharedInstance = GameScoreManager()
    class var instance:GameScoreManager {
        get {
            return sharedInstance
        }
    }
    
    public var MatchDate: NSDate? {
        return self.matchDate
    }
    
    public var YeltzScore: Int {
        return self.yeltzScore
    }
    
    public var OpponentScore: Int {
        return self.opponentScore
    }
    
    init() {
        // Setup local data
        self.moveSingleBundleFileToAppDirectory("gamescore", fileType: "json")
        
        let data:NSData? = NSData.init(contentsOfFile: self.appDirectoryFilePath("gamescore", fileType: "json"))
        
        if (data == nil) {
            print("Couldn't load game score from cache")
            return
        }
        
        do {
            print("Loading game score from cache ...")
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String : AnyObject]
            
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
    
    public func getLatestGameScore() {
        print("Preparing to fetch game score ...")
        
        let dataUrl = NSURL(string: "http://bravelocation.com/automation/feeds/gamescore.json")!
        let urlRequest = NSMutableURLRequest(URL: dataUrl)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (serverData, response, error) -> Void in
            let httpResponse = response as! NSHTTPURLResponse
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
        }
        
        task.resume()
    }
    
    public func loadGameScoreData(data:NSData?) {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String : AnyObject]
            
            if (json == nil) {
                print("Couldn't parse game score from server")
                return
            }
            
            self.parseGameScoreJson(json!)
            
            // Fetch went OK, so write to local file for next startup
            if (self.MatchDate != nil) {
                print("Saving server game score to cache")
                
                try data?.writeToFile(self.appDirectoryFilePath("gamescore", fileType: "json"), options: .DataWritingAtomic)
            }
            
            print("Loaded game score from server")
            
            // Post notification message
            NSNotificationCenter.defaultCenter().postNotificationName(GameScoreManager.GameScoreNotification, object: nil)
        } catch {
            print("Error loading game score from server ...")
            print(error)
        }
    }

    public func CacheFileUrl() -> NSURL {
        return NSURL(fileURLWithPath: appDirectoryFilePath("gamescore", fileType: "json"))
    }
    
    private func parseGameScoreJson(json:[String:AnyObject]) {
        // Clear settings
        self.matchDate = nil
        self.yeltzScore = 0
        self.opponentScore = 0
        
        if let currentMatch = json["match"] {
            if let fixture = Fixture(fromJson: currentMatch as! [String : AnyObject]) {
                self.matchDate = fixture.fixtureDate
            }
        }

        if let parsedYeltzScore = json["yeltzScore"] as? String {
            self.yeltzScore = Int(parsedYeltzScore)!
        }
        
        if let parsedOpponentScore = json["opponentScore"] as? String {
            self.opponentScore = Int(parsedOpponentScore)!
        }
    }
    
    private func moveSingleBundleFileToAppDirectory(fileName:String, fileType:String) {
        if (self.checkAppDirectoryExists(fileName, fileType:fileType))
        {
            // If file already exists, return
            print("GameScore file exists, don't copy from bundle")
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        let bundlePath = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)!
        if fileManager.fileExistsAtPath(bundlePath) == false {
            // No bundle file exists
            print("Missing bundle file")
            return
        }
        
        // Finally, copy the bundle file
        do {
            try fileManager.copyItemAtPath(bundlePath, toPath: self.appDirectoryFilePath(fileName, fileType: fileType))
        }
        catch {
            return
        }
    }
    
    private func appDirectoryFilePath(fileName:String, fileType:String) -> String {
        let appDirectoryPath = self.applicationDirectory()?.path
        let filePath = String.init(format: "%@.%@", fileName, fileType)
        return (appDirectoryPath?.stringByAppendingString(filePath))!
    }
    
    private func checkAppDirectoryExists(fileName:String, fileType:String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        
        return fileManager.fileExistsAtPath(self.appDirectoryFilePath(fileName, fileType:fileType))
    }
    
    private func applicationDirectory() -> NSURL? {
        let bundleId = NSBundle.mainBundle().bundleIdentifier
        let fileManager = NSFileManager.defaultManager()
        var dirPath: NSURL? = nil
        
        // Find the application support directory in the home directory.
        let appSupportDir = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        if (appSupportDir.count > 0) {
            // Append the bundle ID to the URL for the Application Support directory
            dirPath = appSupportDir[0].URLByAppendingPathComponent(bundleId!, isDirectory: true)
            
            do {
                try fileManager.createDirectoryAtURL(dirPath!, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return nil
            }
        }
        
        return dirPath
    }
    
}
