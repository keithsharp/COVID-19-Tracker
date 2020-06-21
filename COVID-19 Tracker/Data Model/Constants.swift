//
//  Constants.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 02/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Foundation

let TIMESTAMP_URL = "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data-last-updated-timestamp.txt"
let DATA_URL = "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv"

let CACHE_FILENAME = "owid-covid-data.csv"

struct Preferences {
    static let DOWNLOADED_DATE = "Preferences.DOWNLOADED_DATE"
}

extension Notification.Name {
    static let modelUpdated = Notification.Name("modelUpdated")
    static let modelFirstLoadComplete = Notification.Name("modelFirstLoadComplete")
}
