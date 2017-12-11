//
//  FixtureManager.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

open class FixtureManager {
    open static let FixturesNotification:String = "YLZFixtureNotification"
    fileprivate var fixtureList:[String:[Fixture]] = [String:[Fixture]]()
    
    fileprivate static let sharedInstance = FixtureManager()
    class var instance:FixtureManager {
        get {
            return sharedInstance
        }
    }
    
    func sync(lock: Any, closure:@escaping () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    open var Months: [String] {
        var result:[String] = []
        
        if (self.fixtureList.keys.count > 0) {
            result = Array(self.fixtureList.keys).sorted()
        }
        
        return result
    }
    
    open func FixturesForMonth(_ monthKey: String) -> [Fixture]? {
        
        if let monthFixtures = self.fixtureList[monthKey] {
            return monthFixtures
        }
        
        return nil
    }
    
    init() {
        // Setup local data
        self.moveSingleBundleFileToAppDirectory("matches", fileType: "json")
        
        let data:Data? = try? Data.init(contentsOf: URL(fileURLWithPath: self.appDirectoryFilePath("matches", fileType: "json")))
        
        if (data == nil) {
            print("Couldn't load fixtures from cache")
            return
        }
        
        do {
            print("Loading fixtures from cache ...")
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String : AnyObject]
            
            if (json == nil) {
                print("Couldn't parse fixtures from cache")
                return
            }
            
            self.parseMatchesJson(json!)
            print("Loaded fixtures from cache")
        } catch {
            print("Error loading fixtures from cache ...")
            print(error)
        }
    }
    
    open func getLatestFixtures() {
        print("Preparing to fetch fixtures ...")
        
        let dataUrl = URL(string: "https://bravelocation.com/automation/feeds/matches.json")!
        let urlRequest = URLRequest(url: dataUrl, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (serverData, response, error) -> Void in
            print("Fixture data received from server")
            if (error != nil) {
                print("Error downloading fixtures from server: \(error.debugDescription)")
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                if (serverData == nil) {
                    print("Couldn't download fixtures from server")
                    return
                }
                
                self.loadFixtureData(serverData);
            } else {
                print("Error response from server: \(statusCode)")
            }
        }) 
        
        task.resume()
        print("Fixtures should be coming on background thread")
    }
    
    open func getAwayGames(_ opponent:String) -> [Fixture] {
        var foundGames:[Fixture] = []
        
        for month in self.Months {
            if let monthFixtures = self.FixturesForMonth(month) {
                for fixture in monthFixtures {
                    if (fixture.opponent == opponent && fixture.home == false) {
                        foundGames.append(fixture)
                    }
                }
            }
        }
        
        return foundGames
    }
    
    open func fixtureCount() -> Int {
        var fixtureCount = 0
        
        for month in self.Months {
            if let monthFixtures = self.FixturesForMonth(month) {
                fixtureCount = fixtureCount + monthFixtures.count
            }
        }
        
        return fixtureCount

    }
    
    open func getLastGame() -> Fixture? {
        var lastCompletedGame:Fixture? = nil
        
        for month in self.Months {
            if let monthFixtures = self.FixturesForMonth(month) {
                for fixture in monthFixtures {
                    if (fixture.teamScore != nil && fixture.opponentScore != nil) {
                        lastCompletedGame = fixture
                    } else {
                        return lastCompletedGame
                    }
                }
            }
        }
        
        return lastCompletedGame;
    }
    
    
    open func getNextGame() -> Fixture? {
        let fixtures = self.GetNextFixtures(1)
        
        if (fixtures.count > 0) {
            return fixtures[0]
        }
        
        return nil;
    }
    
    open func GetNextFixtures(_ numberOfFixtures:Int) -> [Fixture] {
        var fixtures:[Fixture] = []
        let currentDayNumber = self.dayNumber(Date())
        
        for month in self.Months {
            if let monthFixtures = self.FixturesForMonth(month) {
                for fixture in monthFixtures {
                    let matchDayNumber = self.dayNumber(fixture.fixtureDate as Date)
                    
                    // If no score and match is not before today
                    if (fixture.teamScore == nil && fixture.opponentScore == nil && currentDayNumber <= matchDayNumber) {
                        fixtures.append(fixture)
                        
                        if (fixtures.count == numberOfFixtures) {
                            return fixtures
                        }
                    }
                }
            }
        }
        
        return fixtures
    }
    
    open func getCurrentGame() -> Fixture? {
        let nextGame = self.getNextGame()
        
        if (nextGame != nil) {
            // If within 120 minutes of kickoff date, the game is current
            let now = Date()
            let differenceInMinutes = (Calendar.current as NSCalendar).components(.minute, from: nextGame!.fixtureDate as Date, to: now, options: []).minute
            
            if (differenceInMinutes! >= 0 && differenceInMinutes! < 120) {
                return nextGame
            }
        }
        
        return nil
    }
    
    open func loadFixtureData(_ data: Data?) {
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String : AnyObject]
            
            if (json == nil) {
                print("Couldn't parse fixtures from server")
                return
            }
            
            self.parseMatchesJson(json!)
            
            // Fetch went OK, so write to local file for next startup
            if (self.Months.count > 0) {
                print("Saving server fixtures to cache")
                
                try data?.write(to: URL(fileURLWithPath: self.appDirectoryFilePath("matches", fileType: "json")), options: .atomic)
            }
            
            print("Loaded fixtures from server")
            
            // Post notification message
            NotificationCenter.default.post(name: Notification.Name(rawValue: FixtureManager.FixturesNotification), object: nil)
        } catch {
            print("Error loading fixtures from server ...")
            print(error)
        }
    }
    
    fileprivate func parseMatchesJson(_ json:[String:AnyObject]) {
        guard let matches = json["Matches"] as? Array<AnyObject> else { return }
        
        // Open lock on fixtures
        sync (lock: self.fixtureList) {
            self.fixtureList.removeAll()
            
            for currentMatch in matches {
                if let match = currentMatch as? [String:AnyObject] {
                    if let currentFixture = Fixture(fromJson: match) {
                        let monthFixtures = self.FixturesForMonth(currentFixture.monthKey)
                        
                        if monthFixtures != nil {
                            self.fixtureList[currentFixture.monthKey]?.append(currentFixture)
                        } else {
                            self.fixtureList[currentFixture.monthKey] = [currentFixture]
                        }
                    }
                }
            }
            
            // Sort the fixtures per month
            for currentMonth in Array(self.fixtureList.keys) {
                self.fixtureList[currentMonth] = self.fixtureList[currentMonth]?.sorted(by: { $0.fixtureDate.compare($1.fixtureDate as Date) == .orderedAscending })
            }
        }
    }
    
    fileprivate func moveSingleBundleFileToAppDirectory(_ fileName:String, fileType:String) {
        if (self.checkAppDirectoryExists(fileName, fileType:fileType))
        {
            // If file already exists, return
            print("Fixtures file exists, don't copy from bundle")
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
            print("Copied Fixtures from bundle to cache")
        }
        catch {
            print("Problem copying fixtures file from bundle to cache")
            return
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
    
    open func dayNumber(_ date:Date) -> Int {
        // Removes the time components from a date
        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.day, .month, .year]
        let startOfDayComponents = (calendar as NSCalendar).components(unitFlags, from: date)
        let startOfDay = calendar.date(from: startOfDayComponents)
        let intervalToStaryOfDay = startOfDay!.timeIntervalSince1970
        let daysDifference = floor(intervalToStaryOfDay) / 86400  // Number of seconds per day = 60 * 60 * 24 = 86400
        return Int(daysDifference)
    }
}
