//
//  IconModel.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class IconModel {
    let name : String
    let image : UIImage?
    
    init (iconName: String, iconImage: UIImage?) {
        name = iconName
        image = iconImage
    }
}

class IconThemeModel {
    var iconArray = [IconModel]()
    
    init(iconMode: String, alpha: CGFloat = 1) {
        iconArray.append(IconModel.init(iconName: "star", iconImage: UIImage.init(named: "star\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "heart", iconImage: UIImage.init(named: "heart\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "smile", iconImage: UIImage.init(named: "smile\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "thumbs-up", iconImage: UIImage.init(named: "thumbs-up\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "idea", iconImage: UIImage.init(named: "idea\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "home", iconImage: UIImage.init(named: "home\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "toolbox", iconImage: UIImage.init(named: "toolbox\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "coffee", iconImage: UIImage.init(named: "coffee\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "fire", iconImage: UIImage.init(named: "fire\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "sun", iconImage: UIImage.init(named: "sun\(iconMode)")!))
    }
}
