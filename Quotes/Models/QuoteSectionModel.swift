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
    
    init(sectionName: String, sectionIcon: String, isPin: Bool, customPredicate: NSPredicate? = nil) {
        self.sectionName = sectionName
        self.sectionIcon = sectionIcon
        self.isPin = isPin
        self.quotes = getQuotesBySection(pinSection: isPin, customPredicate: customPredicate)
    }
    
    init(sectionName: String, sectionIcon: String, isPin: Bool, collection: String? = nil, customPredicate: NSPredicate? = nil) {
        self.sectionName = sectionName
        self.sectionIcon = sectionIcon
        self.isPin = isPin
        self.quotes = getQuotesBySection(pinSection: isPin, collection: collection, customPredicate: customPredicate)
    }
    
    private func getQuotesBySection(pinSection: Bool, customPredicate: NSPredicate? = nil) -> [Quote] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        var quoteArray = [Quote]()
        
        let sort = [NSSortDescriptor(key: "updatedOn", ascending: false)]
        
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
    
    private func getQuotesBySection(pinSection: Bool, collection: String? = nil, customPredicate: NSPredicate? = nil) -> [Quote] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        var quoteArray = [Quote]()
        
        let sort = [NSSortDescriptor(key: "updatedOn", ascending: false)]
        
        let request : NSFetchRequest<Quote> = Quote.fetchRequest()
        request.sortDescriptors = sort
        
        let predicate = NSPredicate.init(format: "isPin == %@", NSNumber(value: pinSection))
        
        if collection != "" {
            // for colllection
            
            let collectionPredicate = NSPredicate(format: "ANY collections.name == %@", collection!)
            
            if customPredicate != nil {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, collectionPredicate, customPredicate!])
            } else {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, collectionPredicate])
            }
        } else {
            // for ALL
            if customPredicate != nil {
                // for filter
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, customPredicate!])
            } else {
                request.predicate = predicate
            }
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
    
    init(customPredicate: NSPredicate? = nil) {
        quoteSections.append(QuoteSection.init(sectionName: "PINNED QUOTES", sectionIcon: "pin-dark", isPin: true, customPredicate: customPredicate))
        quoteSections.append(QuoteSection.init(sectionName: "QUOTES", sectionIcon: "quote-dark", isPin: false, customPredicate: customPredicate))
    }
    
    init(collection: String? = nil, customPredicate: NSPredicate? = nil) {
        quoteSections.append(QuoteSection.init(sectionName: "PINNED QUOTES", sectionIcon: "pin-dark", isPin: true, collection: collection, customPredicate: customPredicate))
        quoteSections.append(QuoteSection.init(sectionName: "QUOTES", sectionIcon: "quote-dark", isPin: false, collection: collection, customPredicate: customPredicate))
    }
}
