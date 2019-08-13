//
//  MoveCollectionService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit

class MoveCollectionService {
    func show(quotes: [Quote]) -> MoveCollectionViewController {
        let storyboard = UIStoryboard(name: "MoveCollectionStoryboard", bundle: .main)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "MoveCollectionVC") as! MoveCollectionViewController
        
        vc.modalPresentationStyle = .custom
        vc.quotes = quotes
        
        return vc
    }
}
