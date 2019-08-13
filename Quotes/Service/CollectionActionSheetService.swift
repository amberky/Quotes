//
//  CollectionActionSheetService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit

class CollectionActionSheetService {
    func show(collection: CollectionModel) -> CollectionActionSheetViewController {
        let storyboard = UIStoryboard(name: "CollectionActionSheetStoryboard", bundle: .main)

        let actionSheetVC = storyboard.instantiateViewController(withIdentifier: "CollectionActionSheetVC") as! CollectionActionSheetViewController

        actionSheetVC.modalPresentationStyle = .custom
        actionSheetVC.collection = collection

        return actionSheetVC
    }
}
