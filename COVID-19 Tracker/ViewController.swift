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

        NotificationCenter.default.addObserver(self, selector: #selector(onModelUpdate(_:)), name: .modelUpdated, object: nil)
        DispatchQueue.global(qos: .userInitiated).async {
            self.model = DataModel.createDataModel()
            NotificationCenter.default.post(name: .modelUpdated, object: nil)
        }
        
    }

    @objc func onModelUpdate(_ notification:Notification) {
        if let model = model {
            print("Record count: \(model.records.count)")
        } else {
            print("Model is nil?")
        }
    }
    
}

