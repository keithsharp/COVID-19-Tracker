//
//  DataModel.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 20/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Foundation

typealias Countries = [Country]
typealias Records = [Record]

class DataModel {
    private var localLastUpdated: Date?
    private var remoteLastUpdated: Date?
    
    private var _countries: Countries = []
    private var _records: Records = []
    
    var countries: Countries {
        get {
            return _countries
        }
    }
    
    var records: Records {
        get {
            return _records
        }
    }
    
    static func createDataModel() -> DataModel {
        let model = DataModel()
        
        if model.shouldRefreshCache() {
            model.fetchData()
        } else {
            model.refresh()
        }
        
        return model
    }
    
    // Force use of factory method: createDataModel()
    private init() { }
}


// MARK:- Parsing Data
extension DataModel {
    
    private func refresh() {
        parseRecords()
    }
    
    private func parseRecords() {
        let cacheUrl = getCacheFileURL()
        do {
            let data = try Data(contentsOf: cacheUrl)
            let decoder = JSONDecoder()
            let dict = try decoder.decode([String: Records].self, from: data)
            print("Dict size: \(dict.count)")
        } catch {
            print("error:\(error)")
        }
    }
}

// MARK:- Downloading Data
extension DataModel {
    
    private func fetchTimeStamp() {
        guard let url = URL(string: TIMESTAMP_URL) else {
            fatalError("Could not convert TIMESTAMP_URL to URL.")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            if error != nil {
                fatalError("Failed to fetch timestamp URL")
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                fatalError("Timestamp download generated non 2xx repsone")
            }
            
            guard let data = data else {
                fatalError("Got no data when downloading timestamp")
            }
            let timeStampString = String(decoding: data, as: UTF8.self)
            
            let dateFormatter = DateFormatter()
            guard let utc = TimeZone(abbreviation: "UTC") else {
                fatalError("Failed to create UTC TimeZone object")
            }
            dateFormatter.timeZone = utc
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let timeStamp = dateFormatter.date(from: timeStampString) else {
                fatalError("Failed to convert timestamp to date")
            }
            
            self.remoteLastUpdated = timeStamp
        })
        task.resume()
    }
    
    private func fetchData() {
        guard let url = URL(string: DATA_URL) else {
            fatalError("Could not convert DATA_URL to URL.")
        }
               
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            if error != nil {
                fatalError("Failed to fetch data")
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                fatalError("Data download generated non 2xx repsone")
            }
            
            guard let data = data else {
                fatalError("Got no data when trying to download data")
            }
            self.writeDataToCache(data: data)
            self.localLastUpdated = self.remoteLastUpdated
            self.refresh()
        })
        task.resume()
    }
}

// MARK:- Cache File Handling
extension DataModel {
    private func getCacheDirectory() -> URL {
        // Allow this to crash as we should always be able to get a cache directory!
        return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    private func getCacheFileURL() -> URL {
        let directoryURL = getCacheDirectory()
        return directoryURL.appendingPathComponent(CACHE_FILENAME)
    }
    
    private func shouldRefreshCache() -> Bool {
        let cacheFile = getCacheFileURL()
        
        if !FileManager.default.fileExists(atPath: cacheFile.absoluteString) { return true }

        guard let localLastUpdated = localLastUpdated else { return true }

        if remoteLastUpdated == nil {
            fetchTimeStamp() // This should crash if it fails hence the force unwrap below
        }
        if localLastUpdated < remoteLastUpdated! {
            return true
        }
        
        return false
    }
    
    private func writeDataToCache(data: Data) {
        let cacheUrl = getCacheFileURL()
        // Allow this to crash as we should always be able to write to the cache file
        try! data.write(to: cacheUrl, options: .atomic)
    }
}
