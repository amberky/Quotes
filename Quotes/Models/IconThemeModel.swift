//
//  IconModel.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
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
        iconArray.append(IconModel.init(iconName: "thumbs-up", iconImage: UIImage.init(named: "thumbs-up\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "book", iconImage: UIImage.init(named: "book\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "home", iconImage: UIImage.init(named: "home\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "briefcase", iconImage: UIImage.init(named: "briefcase\(iconMode)")!))
//        iconArray.append(IconModel.init(iconName: "gift", iconImage: UIImage.init(named: "gift\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "music", iconImage: UIImage.init(named: "music\(iconMode)")!))
//        iconArray.append(IconModel.init(iconName: "paperclip", iconImage: UIImage.init(named: "paperclip\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "quote", iconImage: UIImage.init(named: "quote\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "fire", iconImage: UIImage.init(named: "fire\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "sun", iconImage: UIImage.init(named: "sun\(iconMode)")!))
    }
}
