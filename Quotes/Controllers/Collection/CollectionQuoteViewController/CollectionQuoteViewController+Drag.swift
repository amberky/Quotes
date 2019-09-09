//
//  QuoteViewController+Drag.swift
//  Quotes
//
//  Created by Kharnyee Eu on 29/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import MobileCoreServices

extension CollectionQuoteViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        return dragItem(indexPath: indexPath, session: session)
    }
    
    func dragItem(indexPath: IndexPath, session: UIDragSession) -> [UIDragItem] {
        let quote = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        
        let data = quote.quote?.data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        return [dragItem]
    }
}

