//
//  MultipleSelectionActionSheetService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 11/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class MultipleSelectionActionSheetService {
    func show(cell: QuoteTableViewCell, objectId: NSManagedObjectID, collection: Collection? = nil) -> MultipleSelectionActionSheetViewController {
        let storyboard = UIStoryboard(name: "MultipleSelectionActionSheetStoryboard", bundle: .main)
        
        let actionSheetVC = storyboard.instantiateViewController(withIdentifier: "MultipleSelectionActionSheetVC") as! MultipleSelectionActionSheetViewController
        
        actionSheetVC.modalPresentationStyle = .custom
        actionSheetVC.cell = cell
        actionSheetVC.objectId = objectId
        actionSheetVC.collection = collection
        
        return actionSheetVC
    }
}
