//
//  SplitViewController.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 02/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {

    var model: DataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.model = DataModel.createDataModel()
            NotificationCenter.default.post(name: .modelFirstLoadComplete, object: self.model)
        }

    }
}
