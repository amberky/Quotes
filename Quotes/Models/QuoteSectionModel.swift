//
//  QuoteSectionModel.swift
//  Quotes
//
//  Created by Kharnyee Eu on 29/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class QuoteSection {
    var sectionName: String
    var sectionIcon: String
    var isPin: Bool
    var quotes: [Quote] = [Quote]()
    
    init(sectionName: String, sectionIcon: String, isPin: Bool) {
        self.sectionName = sectionName
        self.sectionIcon = sectionIcon
        self.isPin = isPin
        self.quotes = getQuotesBySection(pinSection: isPin)
    }
    
    private func getQuotesBySection(pinSection: Bool, customPredicate: NSPredicate? = nil) -> [Quote] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        var quoteArray = [Quote]()
        
        let sort = [NSSortDescriptor(key: "addedOn", ascending: false)]
        
        let request : NSFetchRequest<Quote> = Quote.fetchRequest()
        request.sortDescriptors = sort
        
        let predicate = NSPredicate.init(format: "isPin == %@", NSNumber(value: pinSection))
        
        if (customPredicate != nil) {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, customPredicate!])
        } else {
            request.predicate = predicate
        }

        do {
            quoteArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        return quoteArray
    }
}

class QuoteSections {
    var quoteSections: [QuoteSection] = [QuoteSection]()
    
    init() {
        quoteSections.append(QuoteSection.init(sectionName: "PINNED QUOTES", sectionIcon: "pin-dark", isPin: true))
        quoteSections.append(QuoteSection.init(sectionName: "QUOTES", sectionIcon: "quote-dark", isPin: false))
    }
    
}
