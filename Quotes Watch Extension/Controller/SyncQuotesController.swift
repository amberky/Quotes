//
//  SyncQuotesController.swift
//  Quotes Watch Extension
//
//  Created by Kharnyee Eu on 02/08/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class SyncQuotesController: WKInterfaceController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var syncButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMessageFromPhone(_:)), name: NSNotification.Name(rawValue: "receivedMessageFromPhone"), object: nil)
    }
    
    // MARK: - IBAction
    @IBAction func syncPressed() {
        WatchSessionManager.sharedManager.requestSyncQuotes()
        
        syncButton.setTitle("Syncing...")
    }
    
    // MARK: - Objc Functions
    @objc func receivedMessageFromPhone(_ notification: Notification) {
        guard let success = notification.object as? Bool else { return }
       
        if success {
            // set the title back to sync
            syncButton.setTitle("Sync")
        } else {
            syncButton.setTitle("Sync")
        }
    }
    
}
