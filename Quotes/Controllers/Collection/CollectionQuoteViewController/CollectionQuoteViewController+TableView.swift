//
//  CollectionQuoteViewController+TableView.swift
//  Quotes
//
//  Created by Kharnyee Eu on 17/08/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit

// MARK: - UITableViewDelegate
extension CollectionQuoteViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if quoteSectionArray.count == 0 {
            if searchController.searchBar.text == "" {
                tableView.setEmptyView()
            } else {
                tableView.setNoResultView()
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
        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
        
        if editMode {
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
                } else {
                    favouriteButton.title = "Favourite"
                }
            } else {
                favouriteButton.title = "Favourite"
            }
        } else {
            tableView.beginUpdates()
            if cell.quoteLabel.numberOfLines == 0 {
                cell.quoteLabel.numberOfLines = 2
            } else {
                cell.quoteLabel.numberOfLines = 0
            }
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if editMode == false {
            if searchController.searchBar.isFirstResponder {
                searchController.searchBar.resignFirstResponder()
            }
            
            selectionHaptic.prepare()
            
            let size = 25
            
            let quoteInfo = quoteSectionArray[indexPath.section].quotes[indexPath.row]
            var pinIcon = "star-yellow"
            
            if quoteInfo.isPin == true {
                pinIcon = "unstar-yellow"
            }
            
            let pinAction = UIContextualAction(style: .normal, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                self.selectionHaptic.selectionChanged()
                
                self.pinQuote(indexPath: indexPath)
                completionHandler(true)
            }
            
            let pinImage = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
                UIImage(named: pinIcon)?.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
            }
            
            if let cgImageX =  pinImage.cgImage {
                pinAction.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale , orientation: .up)
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
            
            let size = 35
            
            let action = UIContextualAction(style: .destructive, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                self.selectionHaptic.selectionChanged()
                self.beginEditMode()
                
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                self.selectedRows.append(indexPath)
                
                let quote = self.quoteSectionArray[indexPath.section].quotes[indexPath.row]
                if quote.isPin == true {
                    self.favouriteButton.title = "Unfavourite"
                } else {
                    self.favouriteButton.title = "Favourite"
                }
                
                completionHandler(false)
            }
            
            let image = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
                UIImage(named: "list-blue")?.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
            }
            
            if let cgImageX = image.cgImage {
                action.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
            }
            
            action.backgroundColor = .white
            
            let swipeAction = UISwipeActionsConfiguration(actions: [action])
            //            swipeAction.performsFirstActionWithFullSwipe = false
            
            return swipeAction
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tableViewFrame = tableView.frame.width
        let tableViewLeftMargin = tableView.separatorInset.left
        let tableViewSectionHeight = tableView.sectionHeaderHeight
        let yAxis = (tableViewSectionHeight - 15) / 2
        let width : CGFloat = 20
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let headerInfo = quoteSectionArray[section]
        
        let imageName = headerInfo.sectionIcon
        let image = UIImageView(image: UIImage.init(named: imageName))
        image.frame = CGRect(x: tableViewLeftMargin + 5,
                             y: yAxis,
                             width: width,
                             height: width)
        
        headerView.addSubview(image)
        
        let label = UILabel()
        label.text = headerInfo.sectionName
        label.textColor = .darkGray
        //        label.font = UIFont.boldSystemFont(ofSize: 15)
        
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        
        label.frame = CGRect(x: tableViewLeftMargin + 15 + 15,
                             // table margin left - image width - margin (image - label)
            y: yAxis,
            width: tableViewFrame - (tableViewLeftMargin * 2) - 20 - 10,
            height: width)
        
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
