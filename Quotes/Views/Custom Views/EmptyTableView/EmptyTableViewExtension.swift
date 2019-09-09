//
//  TableViewExtension.swift
//  Quotes
//
//  Created by Kharnyee Eu on 07/08/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit

extension UITableView {
    func setEmptyView() {
        let emptyView = EmptyTableView.init()
        self.backgroundView = emptyView
    }
    
    func setEmptyView(tableView: UITableView) {
        let emptyView = EmptyTableView.init()
        self.backgroundView = emptyView
    }
    
    func setNoResultView() {
        let emptyView = NoResultTableView.init()
        self.backgroundView = emptyView
    }
    
    func setNoResultView(tableView: UITableView) {
        let emptyView = NoResultTableView.init()
        self.backgroundView = emptyView
    }
    
    func removeEmptyView() {
        self.backgroundView = nil
    }
}
