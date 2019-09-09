//
//  QuotesDetailController.swift
//  Quotes Watch Extension
//
//  Created by Kharnyee Eu on 08/08/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class QuotesDetailController: WKInterfaceController {
    
    @IBOutlet weak var quoteLabel: WKInterfaceLabel!
    
    @IBOutlet weak var authorLabel: WKInterfaceLabel!
    
    @IBOutlet weak var bgView: WKInterfaceGroup!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if context != nil {
            let quote = (context as! NSDictionary)["quote"] as? String
            let author = (context as! NSDictionary)["author"] as? String
            let color = (context as! NSDictionary)["color"] as? UIColor
            
            quoteLabel.setText(quote)
            authorLabel.setText(author)
            bgView.setBackgroundColor(color)
        }
    }
}
