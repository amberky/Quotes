//
//  WatchSessionManager.swift
//  Quotes Watch Extension
//
//  Created by Kharnyee Eu on 02/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import Foundation
import  WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    
    private override init() {
        super.init()
    }
    
    private let session = WCSession.default
    
    func startSession() {
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("didReceiveApplicationContext")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedApplicationContext"), object: applicationContext)
        }
    }
    
    func requestSyncQuotes() {
        // when user trigger 'Sync' button
        session.sendMessage(["request" : "pinQuotes"], replyHandler: { (response) in
            print(response)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedMessageFromPhone"), object: true)
            }
            
        }) { (error) in
            print("error")
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedMessageFromPhone"), object: false)
            }
            
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        // phone return message when received watch sync request
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedMessageData"), object: message)
        }
        
//        replyHandler["received": "thank you"]
    }
}
