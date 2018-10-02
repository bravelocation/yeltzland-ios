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
    
    fileprivate var currentFixture:Fixture?
    fileprivate var parseSuccess:Bool = false

    fileprivate static let sharedInstance = GameScoreManager()
    class var instance:GameScoreManager {
        get {
            return sharedInstance
        }
    }
    
    public var CurrentFixture: Fixture? {
        return self.currentFixture
    }
    
    init() {
        // Setup local data
        self.moveSingleBundleFileToAppDirectory("gamescore", fileType: "json")
        
        self.loadDataFromCache()
    }
    
    public func getLatestGameScore() {
        print("Preparing to fetch game score ...")
        
        let dataUrl = URL(string: "https://bravelocation.com/automation/feeds/gamescore.json")!
        let urlRequest = URLRequest(url: dataUrl, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        let session = URLSession.init(configuration: config)
        
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
    
    public func reloadData() {
        self.loadDataFromCache()
    }
    
    fileprivate func loadGameScoreData(_ data:Data?) {
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String : AnyObject]
            
            if (json == nil) {
                print("Couldn't parse game score from server")
                return
            }
            
            self.parseGameScoreJson(json!)
            
            // Fetch went OK, so write to local file for next startup
            if (self.parseSuccess) {
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
        var parsedFixture:Fixture? = nil
        var yeltzScore:Int = 0
        var opponentScore:Int = 0
        
        if let currentMatch = json["match"] {
            if let fixture = Fixture(fromJson: currentMatch as! [String : AnyObject]) {
                parsedFixture = fixture
            }
        }

        if let parsedYeltzScore = json["yeltzScore"] as? String {
            yeltzScore = Int(parsedYeltzScore)!
        }
        
        if let parsedOpponentScore = json["opponentScore"] as? String {
            opponentScore = Int(parsedOpponentScore)!
        }
        
        if let fixture = parsedFixture {
            // Is the game in progress?
            
            if let nextFixture = FixtureManager.instance.getNextGame() {
                if (FixtureManager.instance.dayNumber(nextFixture.fixtureDate) == FixtureManager.instance.dayNumber(fixture.fixtureDate)) {
                    // If current score is on same day as next fixture, then we are in progress
                    self.currentFixture = Fixture(date: fixture.fixtureDate,
                                                  opponent: fixture.opponent,
                                                  home: fixture.home,
                                                  teamScore: yeltzScore,
                                                  opponentScore: opponentScore,
                                                  inProgress: true)
                } else {
                    let now = Date()
                    let afterKickoff = now.compare(nextFixture.fixtureDate) == ComparisonResult.orderedDescending
                    
                    if (afterKickoff) {
                        // If after kickoff, we are in progress with no score yet
                        self.currentFixture = Fixture(date: nextFixture.fixtureDate,
                                                      opponent: nextFixture.opponent,
                                                      home: nextFixture.home,
                                                      teamScore: 0,
                                                      opponentScore: 0,
                                                      inProgress: true)
                    } else if let lastResult = FixtureManager.instance.getLastGame() {
                        // Otherwise "latest score" must be last result
                        self.currentFixture = lastResult
                    }
                    
                }
            }
            
            self.parseSuccess = true
        } else {
            self.parseSuccess = false
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
    
    fileprivate func loadDataFromCache() {
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
    
    fileprivate func appDirectoryFilePath(_ fileName:String, fileType:String) -> String {
        #if os(tvOS)
            let appDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let filePath = String.init(format: "/%@.%@", fileName, fileType)
            return appDirectoryPath + filePath
        #else
            let appDirectoryPath = self.applicationDirectory()?.path
            let filePath = String.init(format: "%@.%@", fileName, fileType)
            return ((appDirectoryPath)! + filePath)
        #endif
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
