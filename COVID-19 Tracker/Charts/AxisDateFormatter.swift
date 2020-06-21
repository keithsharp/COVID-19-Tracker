//
//  AxisDateFormatter.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 21/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Foundation

import Charts

class AxisDateFormatter: IAxisValueFormatter {
    
    let dateFormatter: DateFormatter
    
    init(formatter: DateFormatter) {
        self.dateFormatter = formatter
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}
