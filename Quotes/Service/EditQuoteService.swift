//
//  EditQuoteService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import CoreData

class EditQuoteService {
    func show(cell: QuoteTableViewCell, objectId: NSManagedObjectID) -> EditQuoteViewController {
        let storyboard = UIStoryboard(name: "EditQuoteStoryboard", bundle: .main)

        let vc = storyboard.instantiateViewController(withIdentifier: "EditQuoteVC") as! EditQuoteViewController

        vc.modalPresentationStyle = .custom
        vc.cell = cell
        vc.objectId = objectId

        return vc
    }
}
