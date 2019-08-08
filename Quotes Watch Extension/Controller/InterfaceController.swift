//
//  InterfaceController.swift
//  Quotes Watch Extension
//
//  Created by Kharnyee Eu on 01/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    // MARK: - Variables
    var tableData = [QuoteWatchModel]()
    var colorArray = ColorTheme.init(alpha: 1).colorArray
    
    lazy var colorCount = 0
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    @IBOutlet weak var interfaceGroup: WKInterfaceGroup!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        print("awake")
        
        super.becomeCurrentPage()
        
        // Configure interface objects here.
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedApplicationContext(_:)), name: NSNotification.Name(rawValue: "receivedApplicationContext"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMessage(_:)), name: NSNotification.Name(rawValue: "receivedMessageData"), object: nil)
        
        controlEmptyScreen()
        
        colorCount = colorArray.count
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        print("willActivate")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("didDeactivate")
    }
    
    // MARK: - Objc Functions
    @objc func receivedApplicationContext(_ notification: Notification) {
        print("receivedApplicationContext")
        
        do {
            guard let receivedQuotes = notification.object as? [String: AnyObject] else { return }
            
            let pinQuotes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(receivedQuotes["pinQuotes"] as! Data)
            
            guard let quotesModel = pinQuotes as? [QuoteWatchModel] else { return }
            
            self.tableData = quotesModel
            self.loadTableData()
        } catch {
            print(error)
        }
    }
    
    @objc func receivedMessage(_ notification: Notification) {
        print("receivedMessage")
        
        do {
            guard let receivedQuotes = notification.object as? [String: AnyObject] else { return }
            
            let pinQuotes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(receivedQuotes["pinQuotes"] as! Data)
            
            guard let quotesModel = pinQuotes as? [QuoteWatchModel] else { return }
            
            self.tableData = quotesModel
            self.loadTableData()
        } catch {
            print(error)
        }
        
        super.becomeCurrentPage()
    }
    
    // MARK: - Functions
    private func controlEmptyScreen() {
        if tableData.count > 0 {
            interfaceGroup.setHidden(true)
        } else {
            interfaceGroup.setHidden(false)
        }
    }
    
    private func loadTableData() {
        controlEmptyScreen()
        
        tableView.setNumberOfRows(tableData.count, withRowType: "QuoteTableRowController")
        
        for (index, rowModel) in tableData.enumerated() {
            let mod = index % colorCount
            
            if let rowController = tableView.rowController(at: index) as? QuoteTableRowController {
                rowController.quoteLabel.setText(rowModel.quote)
                rowController.authorLabel.setText(rowModel.author)
                rowController.bgColor.setBackgroundColor(colorArray[mod])
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let data = tableData[rowIndex]
        
        let mod = rowIndex % colorCount
        
        let context = ["quote": data.quote, "author": data.author, "color" : colorArray[mod]] as [String : Any]
        
        presentController(withName: "QuoteDetail", context: context)
    }
}
