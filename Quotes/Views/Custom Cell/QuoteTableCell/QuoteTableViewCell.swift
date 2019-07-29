//
//  QuoteTableViewCell.swift
//  Quotes
//
//  Created by Kharnyee Eu on 23/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class QuoteTableViewCell: UITableViewCell {
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var quote: Quote? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI() {
        quoteLabel.text = quote?.quote
        authorLabel.text = quote?.author
    }
}
