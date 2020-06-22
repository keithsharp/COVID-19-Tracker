//
//  Country.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 02/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Foundation

// See also: https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data-codebook.md

struct Country {
    let code: String
    let name: String
}

extension Country: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}
