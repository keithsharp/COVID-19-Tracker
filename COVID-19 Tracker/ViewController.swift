//
//  ViewController.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 02/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = DataModel.createDataModel()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

