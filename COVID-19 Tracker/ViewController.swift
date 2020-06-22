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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onModelFirstLoadComplete(_:)), name: .modelFirstLoadComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onModelUpdate(_:)), name: .modelUpdated, object: nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.model = DataModel.createDataModel()
            NotificationCenter.default.post(name: .modelFirstLoadComplete, object: nil)
        }
        
        view.addSubview(lineChartView)
        lineChartView.edgesToSuperview()
    }
    
    func drawLineChart() {
        guard let model = model else {
            print("drawLineCHart: Model is nil, that's strange")
            return
        }
        
        let values = model.totalDeathsFor(country: COUNTRY).map {
            ChartDataEntry(x: $0.0, y: $0.1)
        }
        let dataSet = LineChartDataSet(entries: values, label: "\(COUNTRY) Total Deaths")
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        let data = LineChartData(dataSet: dataSet)
        
        lineChartView.data = data
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
            self.drawLineChart()
        }
    }
    
    @objc func onModelUpdate(_ notification:Notification) {
        print("Got model update notification")
        printNumberOfRecords()
    }
    
}

