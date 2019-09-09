//
//  WatchSessionManager.swift
//  Quotes
//
//  Created by Kharnyee Eu on 02/08/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreData

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private override init() {
        super.init()
    }
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    private var validSession: WCSession? {
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        } else {
            return nil
        }
    }
    
    private var validReachableSession: WCSession? {
        if let session = validSession, session.isReachable {
            return session
        } else {
            return nil
        }
    }
    
    
    func updateApplicationContext(applicationContext: [String: AnyObject]) throws {
        if let session = validSession, session.activationState == .activated {
            do {
                try session.updateApplicationContext(applicationContext)
            } catch {
                throw error
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            print("reachable")
        } else {
            print("unreachable")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith")
    }
    
    // WCSessionDelegate methods for iOS only.
    //
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
        
        // Activate the new session after having switched to a new watch.
        
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        if let session = validSession, session.activationState == .activated {
            guard let request = message["request"] as? String else { return }
            
            switch request {
            case "pinQuotes" :
                replyHandler(["response" : "successfully connected to iPhone"])
                
                sendMessageData()
                
            default :
                replyHandler(["response" : "unhandled request message"])
            }
        }
    }
    
    func sendMessageData() {
        DispatchQueue.main.async {
            let updateAppContextService = UpdateAppContextService()
            let quoteData = updateAppContextService.archivedData()
            
            self.session?.sendMessage(quoteData, replyHandler: { (response) in
                print(response)
            }, errorHandler: { (error) in
                print(error)
            })
        }
    }
    
//    func sendPinQuotes() -> [String: AnyObject] {
//        let updateAppContextService = UpdateAppContextService()
//        let quoteData = updateAppContextService.archivedData()
//
//        return ["pinQuotes" : quoteData as AnyObject]
//    }
}
