//
//  QuoteViewController+TableView.swift
//  Quotes
//
//  Created by Kharnyee Eu on 12/08/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit

// MARK: - UITableViewDelegate
extension QuoteViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if quoteSectionArray.count == 0 {
            if searchController.searchBar.text == "" {
                tableView.setEmptyView(tableView: tableView)
            } else {
                tableView.setNoResultView(tableView: tableView)
            }
        } else {
            tableView.removeEmptyView()
        }
        
        return quoteSectionArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteSectionArray[section].quotes.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if editMode {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mod = (indexPath.row + indexPath.section) % colorCount
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        let quote = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        
        cell.quote = quote
        cell.color = colorArray[mod]

        if editMode {
            cell.rowSelectedImage.isHidden = false
            cell.widthConstraint = 30
            
            if self.selectedRows.contains(indexPath) {
                cell.rowSelected = true
            } else {
                cell.rowSelected = false
            }
        } else {
            cell.rowSelectedImage.isHidden = true
            cell.widthConstraint = 0
            cell.rowSelected = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if editMode {
            let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
            
            selectionHaptic.selectionChanged()
            
            if selectedRows.contains(indexPath) {
                cell.rowSelected = false
                selectedRows.remove(at: selectedRows.firstIndex(of: indexPath)!)
                tableView.deselectRow(at: indexPath, animated: false)
            } else {
                cell.rowSelected = true
                selectedRows.append(indexPath)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
            
            let quotes = getSelectedQuotes()
            let group = Dictionary(grouping: quotes ?? [Quote](), by: {$0.isPin})
            if group.count == 1 {
                guard let groupPin = group.first?.value.first! else { return }
                
                if groupPin.isPin == true {
                    favouriteButton.title = "Unfavourite"
                    self.favouriteButton.image = self.heartImage
                } else {
                    favouriteButton.title = "Favourite"
                    self.favouriteButton.image = self.unheartImage
                }
            } else {
                favouriteButton.title = "Favourite"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if editMode == false {
            if searchController.searchBar.isFirstResponder {
                searchController.searchBar.resignFirstResponder()
            }
            
            selectionHaptic.prepare()
            
            let size = 30
            
            let quoteInfo = quoteSectionArray[indexPath.section].quotes[indexPath.row]
            
            
            let pinAction = UIContextualAction(style: .normal, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                self.selectionHaptic.selectionChanged()
                
                self.pinQuote(indexPath: indexPath)
                completionHandler(true)
            }
            
            if quoteInfo.isPin == true {
                pinAction.image = UIIconExtension.init(size: size).unheartPink()
            } else {
                pinAction.image = UIIconExtension.init(size: size).heartpink()
            }
            
            pinAction.backgroundColor = .white
            
            return UISwipeActionsConfiguration(actions: [pinAction])
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if editMode == false {
            if searchController.searchBar.isFirstResponder {
                searchController.searchBar.resignFirstResponder()
            }
            
            let size = 30
  
            let action = UIContextualAction(style: .normal, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                self.selectionHaptic.selectionChanged()
                self.beginEditMode()
                
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                self.selectedRows.append(indexPath)
                
                let quote = self.quoteSectionArray[indexPath.section].quotes[indexPath.row]
                if quote.isPin == true {
                    self.favouriteButton.title = "Unfavourite"
                    self.favouriteButton.image = self.heartImage
                } else {
                    self.favouriteButton.title = "Favourite"
                    self.favouriteButton.image = self.unheartImage
                }
                
                completionHandler(false)
            }
            
            action.image = UIIconExtension.init(size: size).listBlue()
            
            action.backgroundColor = .white
            
            let swipeAction = UISwipeActionsConfiguration(actions: [action])
            
            return swipeAction
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tableViewFrame = tableView.frame.width
        let tableViewLeftMargin = tableView.separatorInset.left
        let tableViewSectionHeight = tableView.sectionHeaderHeight
        let widthHeight : CGFloat = 20
        let yAxis = (tableViewSectionHeight - widthHeight) / 2
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let headerInfo = quoteSectionArray[section]
        
        let imageName = headerInfo.sectionIcon
        let image = UIImageView(image: UIImage.init(named: imageName))
        image.frame = CGRect(x: tableViewLeftMargin + 5, y: yAxis, width: widthHeight, height: widthHeight)
        
        headerView.addSubview(image)
        
        let label = UILabel()
        label.text = headerInfo.sectionName
        label.textColor = .darkGray
        
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        
        label.frame = CGRect(x: tableViewLeftMargin + widthHeight + 15,
                             y: yAxis,
                             width: tableViewFrame - (tableViewLeftMargin * 2) - 20 - 10,
                             height: widthHeight)
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if quoteSectionArray[section].quotes.count == 0 {
            return 0.0
        } else {
            return tableView.sectionHeaderHeight
        }
    }
}
