//
//  ColorThemeModel.swift
//  Quotes Watch Extension
//
//  Created by Kharnyee Eu on 01/08/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit

class ColorTheme {
    var colorArray = [UIColor]()
    
    init(alpha: CGFloat = 1) {
        
        let c1 = UIColor.rgb(red: 235, green: 192, blue: 88, alpha: alpha)
        let c2 = UIColor.rgb(red: 93, green: 117, blue: 153, alpha: alpha)
        
        colorArray.append(c1)
        colorArray.append(c2)
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
