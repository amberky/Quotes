//
//  CollectionActionSheetService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class CollectionActionSheetService {
    func show(collection: CollectionModel) -> CollectionActionSheetViewController {
        let storyboard = UIStoryboard(name: "CollectionActionSheetStoryboard", bundle: .main)

        let collectionActionSheetVC = storyboard.instantiateViewController(withIdentifier: "CollectionActionSheetVC") as! CollectionActionSheetViewController

        collectionActionSheetVC.modalPresentationStyle = .custom
        collectionActionSheetVC.collection = collection

        return collectionActionSheetVC
    }
}
