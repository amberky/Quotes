//
//  SyncQuotesController.swift
//  Quotes Watch Extension
//
//  Created by Kharnyee Eu on 02/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class SyncQuotesController: WKInterfaceController {
    
    
    @IBOutlet weak var syncButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMessageFromPhone(_:)), name: NSNotification.Name(rawValue: "receivedMessageFromPhone"), object: nil)
    }
    
    @objc func receivedMessageFromPhone(_ notification: Notification) {
        guard let success = notification.object as? Bool else { return }
       
        if success {
            // set the title back to sync
            syncButton.setTitle("Sync")
        } else {
            syncButton.setTitle("Sync")
        }
    }
    
    @IBAction func syncPressed() {
        WatchSessionManager.sharedManager.requestSyncQuotes()
        
        syncButton.setTitle("Syncing...")
    }
    
}
