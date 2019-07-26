//
//  QuoteTableViewCell.swift
//  Quotes
//
//  Created by Kharnyee Eu on 23/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

protocol QuoteTableViewCellDelegate {
    func longPressed(cell: QuoteTableViewCell)
    
    func doubleTapped(cell: QuoteTableViewCell)
}

class QuoteTableViewCell: UITableViewCell {

    @IBOutlet weak var quoteHeader: UIView!
    @IBOutlet weak var quoteBackground: UIView!
    @IBOutlet weak var fakeQuoteHeader: UIView!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var favouriteIcon: UIImageView!
    
    var delegate: QuoteTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGestureAction))
        addGestureRecognizer(longPressedGesture)
        
        let doubleTappedGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTappedGestureAction))
        doubleTappedGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTappedGesture)
    }
    
    @objc func longPressedGestureAction() {
        print("long pressed action")
        
        delegate?.longPressed(cell: self)

    }
    
    @objc func doubleTappedGestureAction() {
        
        delegate?.doubleTapped(cell: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
