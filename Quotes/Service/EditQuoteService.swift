//
//  EditQuoteService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class EditQuoteService {
    func show(cell: QuoteTableViewCell) -> EditQuoteViewController {
        let storyboard = UIStoryboard(name: "EditQuoteStoryboard", bundle: .main)

        let editQuoteVC = storyboard.instantiateViewController(withIdentifier: "EditQuoteVC") as! EditQuoteViewController

        editQuoteVC.modalPresentationStyle = .custom
        editQuoteVC.cell = cell

        return editQuoteVC
    }
}
