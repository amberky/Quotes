//
//  SmallIconCollectionViewCell.swift
//  Quotes
//
//  Created by Kharnyee Eu on 25/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit

class SmallIconCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconBackground: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
