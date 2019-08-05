//
//  QuoteActionSheetService.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

class QuoteActionSheetService {
    func show(cell: QuoteTableViewCell, collection: Collection? = nil) -> QuoteActionSheetViewController {
        let storyboard = UIStoryboard(name: "QuoteActionSheetStoryboard", bundle: .main)

        let quoteActionSheetVC = storyboard.instantiateViewController(withIdentifier: "QuoteActionSheetVC") as! QuoteActionSheetViewController

//        quoteActionSheetVC.modalPresentationStyle = .overFullScreen
        quoteActionSheetVC.cell = cell
        quoteActionSheetVC.collection = collection

        return quoteActionSheetVC
    }
}
