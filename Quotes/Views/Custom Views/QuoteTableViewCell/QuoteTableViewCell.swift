//
//  QuoteTableViewCell.swift
//  Quotes
//
//  Created by Kharnyee Eu on 23/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import CoreData

class QuoteTableViewCell: UITableViewCell {
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var selectedButton: UIButton!
    
    @IBOutlet var rowSelectedImage: UIImageView!
    
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
    
    var rowSelected: Bool = false {
        didSet {
            updateCheckedImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI() {
        quoteLabel.text = quote?.quote
        authorLabel.text = quote?.author
        rowSelectedImage.isHidden = true
    }
    
    func setColor() {
        bgView.backgroundColor = color
    }
    
    func updateCheckedImage() {
        if rowSelected {
            rowSelectedImage.image = UIImage.init(named: "checked-blue")
        } else {
            rowSelectedImage.image = UIImage.init(named: "unchecked-blue")
        }
    }
}
