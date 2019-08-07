//
//  EmptyTableView.swift
//  Quotes
//
//  Created by Kharnyee Eu on 02/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class EmptyTableView: UIView {

    var view: UIView!
    
    var noResult: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        guard let nib = Bundle.main.loadNibNamed("EmptyTableView", owner: self, options: nil)?[0] as? UIView else { return }
        nib.frame = bounds
        
        self.addSubview(nib)
    }
}
