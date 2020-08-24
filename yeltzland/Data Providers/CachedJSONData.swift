//
//  CachedJSONData.swift
//  yeltzland
//
//  Created by John Pollard on 07/07/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation

// MARK: - Errors

/// Errors for downloading, loading or parsing JSON
public enum JSONDataError: Error {
    case incorrectFileName
    case missingBundleFile
    case fileSaveError
    case missingCacheData
    case jsonFormatError
    case downloadError
}

// MARK: - CachedJSONData protocol
/// Protocol for files representing cached JSON
protocol CachedJSONData {
    
    // MARK: - Properties
    var fileName: String { get }
    var remoteURL: URL { get }
    var notificationName: Notification.Name { get }
    var fileCoordinator: NSFileCoordinator { get }

    // MARK: - Functions
    init(fileName: String, remoteURL: URL, notificationName: Notification.Name)
    func fetchLatestData(completion: ((Result<Bool, JSONDataError>) -> Void)?)
    func parseJson(_ json: [String: AnyObject]) -> Result<Bool, JSONDataError>
    func isValidJson(_ json: [String: AnyObject]) -> Bool
}

// MARK: - CachedJSONData extension

extension CachedJSONData {
    
    /// The URL of the file in the shared cache
    func cacheFileUrl() -> URL {
        let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.bravelocation.yeltzland")!
        
        return sharedContainerURL.appendingPathComponent(self.fileName)
    }
    
    /// Loads bundle file into cache if it doesn't already exist
    func loadBundleFileIntoCache(completion: (Result<Bool, JSONDataError>) -> Void) {
        let fileManager = FileManager.default
        let cacheFileUrl = self.cacheFileUrl()
        
        if fileManager.fileExists(atPath: cacheFileUrl.path) {
            print("File already exists, don't copy from bundle")
            completion(.success(false))
            return
        }
        
        // Get the file from the bundle
        let fileNameParts = self.fileName.components(separatedBy: ".")
        
        guard fileNameParts.count == 2 else {
            completion(.failure(.incorrectFileName))
            return
        }
        
        let bundlePath = Bundle.main.path(forResource: fileNameParts[0], ofType: fileNameParts[1])!
        if fileManager.fileExists(atPath: bundlePath) == false {
            // No bundle file exists
            completion(.failure(.missingBundleFile))
            return
        }
        
        // Finally, copy the bundle file
        do {
            try fileManager.copyItem(atPath: bundlePath, toPath: cacheFileUrl.path)
            completion(.success(true))
        } catch {
            completion(.failure(.fileSaveError))
        }
    }
    
    /// Loads data from cache
    func loadDataFromCache(completion: (Result<Bool, JSONDataError>) -> Void) {
        self.loadData() { result in
            switch result {
            case .success(let data):
                completion(self.loadJSONFromData(data: data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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
    
    func loadData(completion: ((Result<Data, JSONDataError>) -> Void)) {
        let cacheFileUrl = self.cacheFileUrl()
        
        var error: NSError?
        self.fileCoordinator.coordinate(readingItemAt: cacheFileUrl, options: .withoutChanges, error: &error, byAccessor: { _ in
            do {
                let data = try Data.init(contentsOf: cacheFileUrl)
                completion(.success(data))
            } catch {
                completion(.failure(.missingCacheData))
            }
        })
    }
    
    func saveData(data: Data, completion: ((Result<Bool, JSONDataError>) -> Void)?) {
        let cacheFileUrl = self.cacheFileUrl()
        
        var error: NSError?
        self.fileCoordinator.coordinate(writingItemAt: cacheFileUrl, options: .forReplacing, error: &error, byAccessor: { _ in
            do {
                try data.write(to: cacheFileUrl, options: .atomic)
                completion?(.success(true))
            } catch {
                completion?(.failure(.fileSaveError))
            }
        })
    }
    
    public func fetchLatestData(completion: ((Result<Bool, JSONDataError>) -> Void)?) {
        let urlRequest = URLRequest(url: self.remoteURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
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
                        self.saveData(data: data) { saveResult in
                            // Post notification message
                            NotificationCenter.default.post(name: self.notificationName, object: nil)
                            completion?(saveResult)
                        }
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
