//
//  colorModel.swift
//  Quotes
//
//  Created by Kharnyee Eu on 25/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class ColorTheme {
    var colorArray = [UIColor]()
    
    init(alpha: CGFloat = 1) {
        let c1 = UIColor.rgb(red: 235, green: 192, blue: 88, alpha: 0.2)
        let c2 = UIColor.rgb(red: 93, green: 117, blue: 153, alpha: 0.2)
        
        colorArray.append(c1)
        colorArray.append(c2)
    }
}

extension UIColor {
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 93, green: 117, blue: 153)
    }
    
    static func mainYellow() -> UIColor {
        return UIColor.rgb(red: 235, green: 192, blue: 88)
    }
    
    static func mainLightYellow() -> UIColor {
        return UIColor.rgb(red: 242, green: 224, blue: 177)
    }
    
    static func mainPink() -> UIColor {
        return UIColor.rgb(red: 229, green: 192, blue: 186)
    }
    
    static func mainBeige() -> UIColor {
        return UIColor.rgb(red: 230, green: 227, blue: 226)
    }
    
    static func mainBlack() -> UIColor {
        return UIColor.rgb(red: 35, green: 37, blue: 39)
    }
    
    static func mainUnSelected() -> UIColor {
        return mainBeige()
    }
    
    static func mainSelected() -> UIColor {
        return mainLightYellow()
    }
    
}
