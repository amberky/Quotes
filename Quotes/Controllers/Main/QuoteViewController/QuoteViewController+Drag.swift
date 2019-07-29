//
//  QuoteViewController+Drag.swift
//  Quotes
//
//  Created by Kharnyee Eu on 29/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import MobileCoreServices

extension QuoteViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        return dragItem(indexPath: indexPath, session: session)
    }
    
    func dragItem(indexPath: IndexPath, session: UIDragSession) -> [UIDragItem] {
        guard let quoteSection = quoteSection, let stringData = quoteSection.quotes[indexPath.row].quote!.data(using: .utf8) else {
            return []
        }
        
        let itemProvider = NSItemProvider(item: stringData as NSData, typeIdentifier: kUTTypePlainText as String)
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        session.localContext = (quoteSection, indexPath, tableView)
        
        return [dragItem]
    }
}

