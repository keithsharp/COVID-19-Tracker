//
//  ViewController.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 02/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Cocoa

import Charts
import TinyConstraints

class ViewController: NSViewController {

    var model: DataModel?
    
    lazy var lineChartView: LineChartView = {
        let chart = LineChartView()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM"
        chart.xAxis.valueFormatter = AxisDateFormatter(formatter: dateFormatter)
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        chart.animate(xAxisDuration: 2.5)
        
        chart.noDataText = "Loading data, please be patient"
        
        return chart
    }()
    
    lazy var barChartView: BarChartView = {
        let chart = BarChartView()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM"
        chart.xAxis.valueFormatter = AxisDateFormatter(formatter: dateFormatter)
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        chart.animate(xAxisDuration: 2.5)
        
        chart.noDataText = "Loading data, please be patient"
        
        return chart
    }()
    
    lazy var combinedChartView: CombinedChartView = {
        let chart = CombinedChartView()
        
        chart.rightAxis.drawGridLinesEnabled = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM"
        chart.xAxis.valueFormatter = AxisDateFormatter(formatter: dateFormatter)
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        chart.animate(xAxisDuration: 2.5)
        
        chart.noDataText = "Loading data, please be patient"
        
        return chart
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onModelFirstLoadComplete(_:)), name: .modelFirstLoadComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onModelUpdate(_:)), name: .modelUpdated, object: nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.model = DataModel.createDataModel()
            NotificationCenter.default.post(name: .modelFirstLoadComplete, object: nil)
        }
        
//        view.addSubview(lineChartView)
//        lineChartView.edgesToSuperview()
//        view.addSubview(barChartView)
//        barChartView.edgesToSuperview()
        view.addSubview(combinedChartView)
        combinedChartView.edgesToSuperview()
    }
    
    func printNumberOfRecords() {
        if let model = model {
            print("Record count: \(model.records.count)")
        } else {
            fatalError("Model was nil, oops!")
        }
    }

    @objc func onModelFirstLoadComplete(_ notification:Notification) {
        print("Model first load complete")
        printNumberOfRecords()
        DispatchQueue.main.async {
//            self.drawLineChart()
//            self.drawBarChart()
            self.drawCombinedChart()
        }
    }
    
    @objc func onModelUpdate(_ notification:Notification) {
        print("Got model update notification")
        printNumberOfRecords()
    }
    
}

// MARK:- Chart drawing
extension ViewController {
    func drawLineChart() {
        guard let model = model else {
            print("drawLineChart: Model is nil, that's strange")
            return
        }
        
        let totalDeathsValues: [ChartDataEntry] = model.totalDeathsFor(country: COUNTRY).map {
            return ChartDataEntry(x: $0.0, y: $0.1)
        }
        let totalDeathsDataSet = LineChartDataSet(entries: totalDeathsValues, label: "\(COUNTRY) Total Deaths")
        totalDeathsDataSet.drawCirclesEnabled = false
        totalDeathsDataSet.drawValuesEnabled = false
        let data = LineChartData(dataSet: totalDeathsDataSet)
        
        let newDeathsValues: [ChartDataEntry] = model.newDeathsFor(country: COUNTRY).map {
            return ChartDataEntry(x: $0.0, y: $0.1)
        }
        let newDeathsDataSet = LineChartDataSet(entries: newDeathsValues, label: "\(COUNTRY) Daily Deaths")
        newDeathsDataSet.drawCirclesEnabled = false
        newDeathsDataSet.drawValuesEnabled = false
        newDeathsDataSet.setColor(.systemRed, alpha: 1.0)
        newDeathsDataSet.axisDependency = .right
        data.addDataSet(newDeathsDataSet)
        
        lineChartView.data = data
    }
    
    func drawBarChart() {
        guard let model = model else {
            print("drawBarChart: Model is nil, that's strange")
            return
        }
        
        let newDeathsValues: [ChartDataEntry] = model.newDeathsFor(country: COUNTRY).map {
            return BarChartDataEntry(x: $0.0, y: $0.1)
        }
        let newDeathsDataSet = BarChartDataSet(entries: newDeathsValues, label: "\(COUNTRY) Daily Deaths")
        newDeathsDataSet.setColor(.systemRed, alpha: 1.0)
        let data = BarChartData(dataSet: newDeathsDataSet)
        
        let dataSetRange = newDeathsDataSet.xMax - newDeathsDataSet.xMin
        let availableSpacePerBar = dataSetRange / Double(newDeathsDataSet.count)
        data.barWidth = availableSpacePerBar * 0.8 // 80% of available space
        
        barChartView.data = data
    }
    
    func drawCombinedChart() {
        guard let model = model else {
            print("drawCombinedChart: Model is nil, that's strange")
            return
        }
        
        let newDeathsValues: [ChartDataEntry] = model.newDeathsFor(country: COUNTRY).map {
            return BarChartDataEntry(x: $0.0, y: $0.1)
        }
        let newDeathsDataSet = BarChartDataSet(entries: newDeathsValues, label: "\(COUNTRY) Daily Deaths")
        newDeathsDataSet.setColor(.systemRed, alpha: 1.0)
        newDeathsDataSet.axisDependency = .right
        let newDeathsBarData = BarChartData(dataSet: newDeathsDataSet)
        
        let dataSetRange = newDeathsDataSet.xMax - newDeathsDataSet.xMin
        let availableSpacePerBar = dataSetRange / Double(newDeathsDataSet.count)
        newDeathsBarData.barWidth = availableSpacePerBar * 0.8 // 80% of available space
        
        let totalDeathsValues: [ChartDataEntry] = model.totalDeathsFor(country: COUNTRY).map {
            return ChartDataEntry(x: $0.0, y: $0.1)
        }
        let totalDeathsDataSet = LineChartDataSet(entries: totalDeathsValues, label: "\(COUNTRY) Total Deaths")
        totalDeathsDataSet.drawCirclesEnabled = false
        totalDeathsDataSet.drawValuesEnabled = false
        let totalDeathsLineData = LineChartData(dataSet: totalDeathsDataSet)
        
        let data = CombinedChartData()
        data.lineData = totalDeathsLineData
        data.barData = newDeathsBarData
        combinedChartView.data = data
    }
}
