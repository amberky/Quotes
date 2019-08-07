//
//  QuoteViewController+SearchBar.swift
//  Quotes
//
//  Created by Kharnyee Eu on 29/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

// MARK: - Search Bar methods
extension QuoteViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchQuote(searchBar: searchBar, hideKeyboard: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchQuote(searchBar:hideKeyboard:)), object: searchBar)
        self.perform(#selector(searchQuote(searchBar:hideKeyboard:)), with: searchBar, afterDelay: 0.1)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        tableView.dragInteractionEnabled = true
        searchQuote(searchBar: searchBar, hideKeyboard: true)
    }
    
    @objc func searchQuote(searchBar : UISearchBar, hideKeyboard : Bool = false) {
        if searchBar.text?.count == 0 {
            loadQuotes()
        }
        else {
            let predicate = NSPredicate(format: "quote CONTAINS[cd] %@ or author CONTAINS[cd] %@", searchBar.text!, searchBar.text!)
            
            loadQuotes(predicate: predicate)
        }
        
//        if quoteSectionArray.count > 0 {
//            tableView.scrollsToTop = true
//        }
                
        if hideKeyboard {
            //Dispatch Queue assign the task to different threads
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

