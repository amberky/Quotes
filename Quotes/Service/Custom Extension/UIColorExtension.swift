//
//  UIColorExtension.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

extension UIColor {
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 93, green: 117, blue: 153)
    }
    
    static func mainPink() -> UIColor {
        return UIColor.rgb(red: 227, green: 218, blue: 210)
    }
    
    static func mainBeige() -> UIColor {
        return UIColor.rgb(red: 227, green: 218, blue: 210)
    }
    
    static func mainBlack() -> UIColor {
        return UIColor.rgb(red: 35, green: 37, blue: 39)
    }
    
    static func mainUnSelected() -> UIColor {
        return UIColor.rgb(red: 230, green: 227, blue: 226)
    }
    
    static func mainSelected() -> UIColor {
        return UIColor.rgb(red: 170, green: 184, blue: 187)
    }
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

