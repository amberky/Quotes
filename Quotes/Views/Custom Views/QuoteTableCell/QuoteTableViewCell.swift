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
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var quoteHeader: UIView!
    @IBOutlet weak var fakeQuoteHeader: UIView!
    
    var quote: Quote? {
        didSet {
            updateUI()
        }
    }
    
    var color: UIColor? {
        didSet {
            setColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI() {
        quoteLabel.text = quote?.quote
        authorLabel.text = quote?.author
    }
    
    func setColor() {
        borderView.backgroundColor = color
        bgView.backgroundColor = color
       
//        quoteHeader.backgroundColor = .clear
//        fakeQuoteHeader.backgroundColor = .clear
        
//        quoteHeader.clipsToBounds = true
        
    }
}
