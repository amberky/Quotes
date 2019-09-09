//
//  CollectionTableViewCell.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {

    let checked = "✓"
    let interminate = "-"
    let unchecked = ""
    
    @IBOutlet weak var collectionLabel: UILabel!
    
    @IBOutlet var selectionLabel: UILabel!
    
     var collection: Collection? {
           didSet {
               updateUI()
           }
       }
    
    var rowSelected: Int = -1 {
        didSet {
            updateCheckedImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI() {
        collectionLabel.text = collection?.name
    }

    func updateCheckedImage() {
        if self.rowSelected == 0 {
            self.selectionLabel.text = self.checked
        } else if self.rowSelected == 1 {
            self.selectionLabel.text = self.interminate
        } else {
            self.selectionLabel.text = self.unchecked
        }
    }
}
