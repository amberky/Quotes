//
//  QuoteActionSheetService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import CoreData

class QuoteActionSheetService {
    func show(quotes: [Quote], collection: Collection? = nil) -> QuoteActionSheetViewController {
        let storyboard = UIStoryboard(name: "QuoteActionSheetStoryboard", bundle: .main)
        
        let actionSheetVC = storyboard.instantiateViewController(withIdentifier: "QuoteActionSheetVC") as! QuoteActionSheetViewController
        
        actionSheetVC.quotes = quotes
        actionSheetVC.collection = collection
        
        return actionSheetVC
    }
}
