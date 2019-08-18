//
//  UIIconExtension.swift
//  Quotes
//
//  Created by Kharnyee Eu on 18/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class UIIconExtension {
    var size = 40
    
    init(size: Int) {
        self.size = size
    }
    
    func heart() -> UIImage? {
        return convertToUIImage(imageName: "heart-thin-light")
    }
    
    func unheart() -> UIImage? {
        return convertToUIImage(imageName: "unheart-thin-light")
    }
    
    func heartpink() -> UIImage? {
        return convertToUIImage(imageName: "heart-thin-pink")
    }
    
    func unheartPink() -> UIImage? {
        return convertToUIImage(imageName: "unheart-thin-pink")
    }
    
    func download() -> UIImage? {
        return convertToUIImage(imageName: "download-thin-light")
    }
    
    func edit() -> UIImage? {
        return convertToUIImage(imageName: "pencil-blue")
    }
    
    func folder() -> UIImage? {
        return convertToUIImage(imageName: "unfill-folder-light")
    }
    
    func delete() -> UIImage? {
        return convertToUIImage(imageName: "trash-light")
    }
    
    func share() -> UIImage? {
        return convertToUIImage(imageName: "share-light")
    }
    
    func listBlue() -> UIImage? {
        return convertToUIImage(imageName: "list-blue")
    }
    
    private func convertToUIImage(imageName: String) -> UIImage? {
        let image = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
            UIImage(named: imageName)?.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
        
        if let cgImage = image.cgImage {
            return ImageWithoutRender(cgImage: cgImage, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        
        return nil
    }
}
