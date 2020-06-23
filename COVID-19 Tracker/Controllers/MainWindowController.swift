//
//  MainWindowController.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 21/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.title = "COVID-19 Tracker"
        self.windowFrameAutosaveName = "position"
    }

}
