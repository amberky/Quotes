//
//  MoveCollectionService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class MoveCollectionService {
    func show(cell: QuoteTableViewCell) -> MoveCollectionViewController {
        let storyboard = UIStoryboard(name: "MoveCollectionStoryboard", bundle: .main)
        
        let moveCollectionVC = storyboard.instantiateViewController(withIdentifier: "MoveCollectionVC") as! MoveCollectionViewController
        
        moveCollectionVC.modalPresentationStyle = .custom
        moveCollectionVC.cell = cell
        
        return moveCollectionVC
    }
}
