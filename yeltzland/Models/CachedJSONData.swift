//
//  CachedJSONData.swift
//  yeltzland
//
//  Created by John Pollard on 07/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation

enum JSONDataError: Error {
    case incorrectFileName
    case missingBundleFile
    case fileSaveError
    case missingCacheData
    case jsonFormatError
    case downloadError
}

protocol CachedJSONData {
    var fileName: String { get }
    var remoteURL: URL { get }
    var notificationName: String { get }

    init(fileName: String, remoteURL: URL, notificationName: String)
    func fetchLatestData(completion: ((Result<Bool, JSONDataError>) -> Void)?)
    
    func parseJson(_ json: [String: AnyObject]) -> Result<Bool, JSONDataError>
    func isValidJson(_ json: [String: AnyObject]) -> Bool
}

extension CachedJSONData {
    
    /// The URL of the file in the shared cache
    func cacheFileUrl() -> URL {
        let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.bravelocation.yeltzland")!
        
        return sharedContainerURL.appendingPathComponent(self.fileName)
    }
    
    /// Loads bundle file into cache if it doesn't already exist
    func loadBundleFileIntoCache() -> Result<Bool, JSONDataError> {
        let fileManager = FileManager.default
        let cacheFileUrl = self.cacheFileUrl()
        
        if fileManager.fileExists(atPath: cacheFileUrl.path) {
            print("File already exists, don't copy from bundle")
            return .success(false)
        }
        
        // Get the file from the bundle
        let fileNameParts = self.fileName.components(separatedBy: ".")
        
        guard fileNameParts.count == 2 else { return .failure(.incorrectFileName) }
        
        let bundlePath = Bundle.main.path(forResource: fileNameParts[0], ofType: fileNameParts[1])!
        if fileManager.fileExists(atPath: bundlePath) == false {
            // No bundle file exists
            return .failure(.missingBundleFile)
        }
        
        // Finally, copy the bundle file
        do {
            try fileManager.copyItem(atPath: bundlePath, toPath: cacheFileUrl.path)
            return .success(true)
        } catch {
            return .failure(.fileSaveError)
        }
    }
    
    /// Loads data from cache
    func loadDataFromCache() -> Result<Bool, JSONDataError> {
        guard let data = self.loadData() else {
            return .failure(.missingCacheData)
        }
        
        return self.loadJSONFromData(data: data)
    }
    
    func loadJSONFromData(data: Data) -> Result<Bool, JSONDataError> {
        do {
            print("Loading data from cache ...")
            if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] {
                return self.parseJson(json)
            } else {
                return .failure(.jsonFormatError)
            }
        } catch {
            print("Error loading data from cache ...")
            print(error)
            return .failure(.jsonFormatError)
        }
    }
    
    func loadData() -> Data? {
        // TODO: Make thread-safe
        
        let cacheFileUrl = self.cacheFileUrl()
        return try? Data.init(contentsOf: cacheFileUrl)
    }
    
    func saveData(data: Data) -> Result<Bool, JSONDataError> {
        // TODO: Make thread-safe
        let cacheFileUrl = self.cacheFileUrl()
        do {
            try data.write(to: cacheFileUrl, options: .atomic)
            return .success(true)
        } catch {
            return .failure(.fileSaveError)
        }
    }
    
    func fetchLatestData(completion: ((Result<Bool, JSONDataError>) -> Void)?) {
        let urlRequest = URLRequest(url: self.remoteURL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        let session = URLSession.init(configuration: config)
        
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (serverData, response, error) -> Void in
            if (error != nil) {
                print("Error downloading game score from server: \(error.debugDescription)")
                completion?(.failure(.downloadError))
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                if let data = serverData {
                    let parseResult = self.loadJSONFromData(data: data)
                    
                    switch parseResult {
                    case .success:
                        // JSON is good, so save it
                        let saveResult = self.saveData(data: data)
                        
                        // Post notification message
                        NotificationCenter.default.post(name: Notification.Name(rawValue: self.notificationName), object: nil)
                        
                        completion?(saveResult)
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                } else {
                    print("Couldn't download data from server")
                    completion?(.failure(.downloadError))
                }
            } else {
                print("Error response from server: \(statusCode)")
                completion?(.failure(.downloadError))
            }
        })
        
        task.resume()
    }
}
