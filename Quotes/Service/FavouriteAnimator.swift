//
//  FavouriteAnimator.swift
//  Quotes
//
//  Created by Kharnyee Eu on 26/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class FavouriteAnimator {
    
    let container: UIView
    let layoutConstraints: NSLayoutConstraint
    
    init(container: UIView, layoutConstraints: NSLayoutConstraint) {
        self.container = container
        self.layoutConstraints = layoutConstraints
    }
    
    func animate(completion: @escaping () -> Void) {
        layoutConstraints.constant = 15
        
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 2,
                       options: .curveLinear,
                       animations: { [weak self] in
                        self?.container.layoutIfNeeded()
        }) { [weak self] (_) in
            
            self?.layoutConstraints.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self?.container.layoutIfNeeded()
                completion()
            })
        }
    }
}
