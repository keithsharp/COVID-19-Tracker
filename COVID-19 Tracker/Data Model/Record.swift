//
//  Record.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 02/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Foundation

//"location": "Afghanistan",
//"date": "2020-06-02",
//"total_cases": 15750,
//"new_cases": 545,
//"total_deaths": 265,
//"new_deaths": 8,
//"total_cases_per_million": 404.59,
//"new_cases_per_million": 14,
//"total_deaths_per_million": 6.807,
//"new_deaths_per_million": 0.206,
//"population": 38928341,
//"population_density": 54.422,
//"median_age": 18.6,
//"aged_65_older": 2.581,
//"aged_70_older": 1.337,
//"gdp_per_capita": 1803.987,
//"cvd_death_rate": 597.029,
//"diabetes_prevalence": 9.59,
//"handwashing_facilities": 37.746,
//"hospital_beds_per_100k": 0.5

// See also: https://github.com/owid/covid-19-data/blob/master/public/data/owid-covid-data-codebook.md

struct Record {
    var location: String
    var date: Date
    var totalCases: Int?
    var newCases: Int?
    var totalDeaths: Int?
    var newDeaths: Int?
}
