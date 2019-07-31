//
//  ActionSheetService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class ActionSheetService {
    func show(cell: QuoteTableViewCell) -> ActionSheetViewController {
        let storyboard = UIStoryboard(name: "ActionSheetStoryboard", bundle: .main)

        let actionSheetVC = storyboard.instantiateViewController(withIdentifier: "ActionSheetVC") as! ActionSheetViewController

        actionSheetVC.modalPresentationStyle = .custom
        actionSheetVC.cell = cell

        return actionSheetVC
    }
}
