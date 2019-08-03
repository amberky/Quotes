//
//  CollectionCollectionViewCell.swift
//  Quotes
//
//  Created by Kharnyee Eu on 24/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class CollectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionImage: UIImageView!
    @IBOutlet weak var collectionLabel: UILabel!
    @IBOutlet weak var quoteCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        collectionImageLabel.font = UIFont.init(name: "FontAwesome5Free-Solid", size: 40)
//        collectionImageLabel.tintColor = .white
    }
}
