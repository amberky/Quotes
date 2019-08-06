//
//  UpdateAppContextService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 02/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreData

class UpdateAppContextService {
    func updateAppContext() {
        do {
            let quoteData = archivedData()
            
            try WatchSessionManager.sharedManager.updateApplicationContext(applicationContext: quoteData)
        } catch {
            print("Error in update app context: \(error)")
        }
    }
    
    func archivedData() -> [String: AnyObject] {
        let pinQuotes = getPinnedQuotes()
        
        let data = try? NSKeyedArchiver.archivedData(withRootObject: pinQuotes, requiringSecureCoding: false)
        
        guard let quoteData = data else { return [:] }
        
        return ["pinQuotes": quoteData as AnyObject]
    }
    
    private func getPinnedQuotes() -> [QuoteWatchModel] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        var quoteArray = [QuoteWatchModel]()
        
        let sort = [NSSortDescriptor(key: "updatedOn", ascending: false)]
        
        let request : NSFetchRequest<Quote> = Quote.fetchRequest()
        request.sortDescriptors = sort
        
        let predicate = NSPredicate.init(format: "isPin == %@", NSNumber(value: true))
        request.predicate = predicate
        
        do {
            let quoteContext = try context.fetch(request)
            
            for i in quoteContext {
                quoteArray.append(QuoteWatchModel.init(quote: i.quote ?? "", author: i.author ?? ""))
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        return quoteArray
    }
}
