//
//  DataModel+Charts.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 21/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Foundation

extension DataModel {
    
    func totalDeathsFor(country: String, from: Date? = nil, to: Date? = nil) -> [(Double, Double)]{
        
        var fromDate: Date
        var toDate: Date
        
        if from == nil {
            fromDate = Date(timeIntervalSince1970: 0)
        } else {
            fromDate = from!
        }
        
        if to == nil {
            toDate = Date(timeIntervalSinceNow: 86401) // Tomorrow
        } else {
            toDate = to!
        }
        
        let filteredRecords = records.filter {
            $0.location == country && $0.totalDeaths != nil && $0.date >= fromDate && $0.date <= toDate
        }
        
        return filteredRecords.compactMap {
            ($0.date.timeIntervalSince1970, $0.totalDeaths!)
        }
    }
    
    func newDeathsFor(country: String, from: Date? = nil, to: Date? = nil) -> [(Double, Double)]{
        
        var fromDate: Date
        var toDate: Date
        
        if from == nil {
            fromDate = Date(timeIntervalSince1970: 0)
        } else {
            fromDate = from!
        }
        
        if to == nil {
            toDate = Date(timeIntervalSinceNow: 86401) // Tomorrow
        } else {
            toDate = to!
        }
        
        let filteredRecords = records.filter {
            $0.location == country && $0.newDeaths != nil && $0.date >= fromDate && $0.date <= toDate
        }
        
        return filteredRecords.compactMap {
            ($0.date.timeIntervalSince1970, $0.newDeaths!)
        }
    }
    
}
