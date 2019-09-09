//
//  QuoteWatchModel.swift
//  Quotes Watch Extension
//
//  Created by Kharnyee Eu on 01/08/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import Foundation

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
