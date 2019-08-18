//
//  QuoteSectionModel.swift
//  Quotes
//
//  Created by Kharnyee Eu on 29/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
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
        let pinned = QuoteSection.init(sectionName: "FAVOURITE QUOTES", sectionIcon: "heart-thin-darkgray", isPin: true, customPredicate: customPredicate)
        
        if pinned.quotes.count > 0 {
            quoteSections.append(pinned)
        }
        
        let unpinned = QuoteSection.init(sectionName: "QUOTES", sectionIcon: "quote-darkgray", isPin: false, customPredicate: customPredicate)
        
        if unpinned.quotes.count > 0 {
            quoteSections.append(unpinned)
        }
    }
    
    init(collection: String? = nil, customPredicate: NSPredicate? = nil) {
        let pinned = QuoteSection.init(sectionName: "FAVOURITE QUOTES", sectionIcon: "heart-thin-darkgray", isPin: true, collection: collection, customPredicate: customPredicate)
        
        if pinned.quotes.count > 0 {
            quoteSections.append(pinned)
        }
        
        let unpinned = QuoteSection.init(sectionName: "QUOTES", sectionIcon: "quote-darkgray", isPin: false, collection: collection, customPredicate: customPredicate)
        
        if unpinned.quotes.count > 0{
            quoteSections.append(unpinned)
        }
    }
}

@objc(QuoteWatchModel)
class QuoteWatchModel: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(quote, forKey:"quote")
        aCoder.encode(author, forKey:"author")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.quote = aDecoder.decodeObject(forKey: "quote") as? String ?? ""
        self.author = aDecoder.decodeObject(forKey: "author") as? String ?? ""
    }
    
    let quote: String
    let author: String
    
    init(quote: String, author: String) {
        self.quote = quote
        self.author = author
    }
}
