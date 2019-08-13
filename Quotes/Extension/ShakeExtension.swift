//
//  ShakeExtension.swift
//  Quotes
//
//  Created by Kharnyee Eu on 06/08/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit

extension UIView {
    func Shake(){
        let impact = UIImpactFeedbackGenerator()
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 5, y: self.center.y))
        
        self.layer.removeAnimation(forKey: "position")
        
        impact.impactOccurred()
        self.layer.add(animation, forKey: "position")
    }
}
