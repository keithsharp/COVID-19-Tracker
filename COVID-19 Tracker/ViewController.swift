//
//  ViewController.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 02/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var model: DataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onModelFirstLoadComplete(_:)), name: .modelFirstLoadComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onModelUpdate(_:)), name: .modelUpdated, object: nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.model = DataModel.createDataModel()
            NotificationCenter.default.post(name: .modelFirstLoadComplete, object: nil)
        }
        
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
    }
    
    @objc func onModelUpdate(_ notification:Notification) {
        print("Got model update notification")
        printNumberOfRecords()
    }
    
}

