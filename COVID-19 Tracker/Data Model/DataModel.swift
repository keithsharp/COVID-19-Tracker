//
//  DataModel.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 20/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Foundation
import SwiftCSV

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
        model.fetchTimeStamp()
        
        if model.shouldRefreshCache() {
            model.fetchData()
        } else {
            model.parse()
        }
        
        return model
    }
    
    // Force use of factory method createDataModel()
    private init() {
        let defaults = UserDefaults.standard
        self.localLastUpdated = defaults.object(forKey: Preferences.DOWNLOADED_DATE) as? Date
    }
}


// MARK:- Parsing Data
extension DataModel {
    
    private func parse() {
        let url = getCacheFileURL()
        do {
            let csv = try CSV(url: url)
            try csv.enumerateAsDict { dict in
                if let record = self.parseRecord(dict: dict) {
                    self._records.append(record)
                }
            }
        } catch {
            fatalError("Failed to parse CSV file")
        }
    }
    
    private func parseRecord(dict: [String: String] ) -> Record? {
        guard let location = dict["location"] else { return nil }
        
        guard let dateString = dict["date"] else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        
        var totalCases: Int?
        if let tc = dict["total_cases"] {
            totalCases = Int(tc)
        }
        
        var newCases: Int?
        if let nc = dict["new_cases"] {
            newCases = Int(nc)
        }
        
        var totalDeaths: Int?
        if let td = dict["total_deaths"] {
            totalDeaths = Int(td)
        }
        
        var newDeaths: Int?
        if let nd = dict["new_deaths"] {
            newDeaths = Int(nd)
        }
        
        return Record(location: location, date: date, totalCases: totalCases, newCases: newCases, totalDeaths: totalDeaths, newDeaths: newDeaths)
    }
}

// MARK:- Downloading Data
extension DataModel {
    
    private func fetchTimeStamp() {
        
        let sem = DispatchSemaphore.init(value: 0)
        
        guard let url = URL(string: TIMESTAMP_URL) else {
            fatalError("Could not convert TIMESTAMP_URL to URL.")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            defer { sem.signal() }
            
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
        
        sem.wait()
    }
    
    private func fetchData() {
        
        let sem = DispatchSemaphore.init(value: 0)
        
        print("DOWNLOADING")
        guard let url = URL(string: DATA_URL) else {
            fatalError("Could not convert DATA_URL to URL.")
        }
               
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            defer { sem.signal() }
            
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
            let defaults = UserDefaults.standard
            defaults.set(self.localLastUpdated, forKey: Preferences.DOWNLOADED_DATE)
            self.parse()
        })
        task.resume()
        
        sem.wait()
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
        
        if !FileManager.default.isReadableFile(atPath: cacheFile.path) { return true }

        guard let localLastUpdated = localLastUpdated else { return true }

        if remoteLastUpdated == nil {
            // This should crash if it fails hence the force unwrap below
            fetchTimeStamp()
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
