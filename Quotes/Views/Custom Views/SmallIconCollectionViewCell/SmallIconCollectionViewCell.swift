//
//  SmallIconCollectionViewCell.swift
//  Quotes
//
//  Created by Kharnyee Eu on 25/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class SmallIconCollectionViewCell: UICollectionViewCell {

//    @IBOutlet var viewCell: SmallIconCollectionViewCell!
    
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
        // Initialization code
        
//        iconLabel.font = UIFont.init(name: "FontAwesome5Free-Solid", size: 30)
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
