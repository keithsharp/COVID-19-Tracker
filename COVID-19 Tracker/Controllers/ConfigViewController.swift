//
//  ConfigViewController.swift
//  COVID-19 Tracker
//
//  Created by Keith Sharp on 23/06/2020.
//  Copyright © 2020 Keith Sharp. All rights reserved.
//

import Cocoa

class ConfigViewController: NSViewController {

    var model: DataModel?
    var chartViewController: ChartViewController!
    
    @IBOutlet weak var countryPopUpButton: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onModelFirstLoadComplete(_:)), name: .modelFirstLoadComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onModelUpdate(_:)), name: .modelUpdated, object: nil)
        
        guard let svc = parent as? NSSplitViewController else {
            fatalError("ConfigViewController - parent ViewController isn't a NSSplitViewController")
        }
        guard let chartViewController = svc.splitViewItems[0].viewController as? ChartViewController else {
            fatalError("ConfigViewController - could not get ChartViewController from SplitViewController")
        }
        self.chartViewController = chartViewController
        
        configureCountryPopUpButton()
    }
    
    @IBAction func countryPopUpButtonChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        guard let item = sender.item(at: index) else { return }
        chartViewController.drawCombinedChartFor(country: item.title)
    }
    
}

// MARK:- Setup User Interface
extension ConfigViewController {
    func configureCountryPopUpButton() {
        // Disable UI until model is loaded
        countryPopUpButton.isEnabled = false
        
        guard let model = model else { return }
        
        countryPopUpButton.removeAllItems()
        
        let countries = model.countries.map {
            $0.name
        }.sorted()
        
        countryPopUpButton.addItems(withTitles: countries)
    }
}

// MARK:- Notification Observers
extension ConfigViewController {
    @objc func onModelFirstLoadComplete(_ notification:Notification) {
        if let model = notification.object as? DataModel {
            self.model = model
        } else {
            fatalError("ConfigViewController::onModelFirstLoadComplete without valid model")
        }
        print("ConfigViewController - Model first load complete")
        DispatchQueue.main.async {
            self.configureCountryPopUpButton()
            self.countryPopUpButton.isEnabled = true
        }
    }
        
    @objc func onModelUpdate(_ notification:Notification) {
        print("Got model update notification")
        // Do something here, but remember the need for the main thread
    }
}
