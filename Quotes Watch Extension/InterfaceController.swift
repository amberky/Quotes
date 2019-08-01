//
//  InterfaceController.swift
//  Quotes Watch Extension
//
//  Created by Kharnyee Eu on 01/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    let tableData = ["Focusing is about saying no", "Because people who are crazy enough to think that they can change the world are the ons who do", "Three", "Four", "Five", "Six"]
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        loadTableData()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func getPinQuotes(){
        
    }
    
    private func loadTableData() {
        tableView.setNumberOfRows(tableData.count, withRowType: "QuoteTableRowController")
        
        for (index, rowModel) in tableData.enumerated() {
            if let rowController = tableView.rowController(at: index) as? QuoteTableRowController {
                rowController.quoteLabel.setText(rowModel)
                rowController.authorLabel.setText("Steve Jobs")
            }
        }
    }
}

