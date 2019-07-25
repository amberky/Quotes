//
//  AddEditCollectionView.swift
//  Quotes
//
//  Created by Kharnyee Eu on 25/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class AddEditCollectionView: UIView {
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var collectionLabel: UILabel!
    
    @IBOutlet weak var collectionTextField: UITextField!
    
    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("NSCoder")
        setup()
    }
    
    override init(frame: CGRect) {
        print("frame")
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed("AddEditCollectionView", owner: self, options: nil)
        
        print("subview self: \(self.view.frame.width)")
        print("subview iconCollectionView: \(iconCollectionView.frame.width)")
       
        self.addSubview(view)
    }
}
