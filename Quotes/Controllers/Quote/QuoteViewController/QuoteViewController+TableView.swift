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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cellForRowAt")
        let mod = (indexPath.row + indexPath.section) % colorCount
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        let quote = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        
        cell.quote = quote
        cell.color = colorArray[mod]
        
        if editMode {
            cell.rowSelectedImage.isHidden = false
            
            if selectedRows.contains(indexPath) {
                cell.rowSelected = true
            } else {
                cell.rowSelected = false
            }
        } else {
            cell.rowSelectedImage.isHidden = true
            cell.rowSelected = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hi")
        
        //let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
        
//        if editMode {
//            selectedRows.append(indexPath)
//            cell.rowSelected = true
//        } else {
//            tableView.beginUpdates()
//            cell.quoteLabel.numberOfLines = 0
//            tableView.endUpdates()
//        }
    }
    
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        print("Deselect")
//        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
//
//        if editMode {
//            guard let index = selectedRows.firstIndex(of:indexPath) else { return }
//
//            selectedRows.remove(at: index)
//            cell.rowSelected = false
//        } else {
//            tableView.beginUpdates()
//            cell.quoteLabel.numberOfLines = 2
//            tableView.endUpdates()
//        }
//    }
    
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
        image.frame = CGRect(x: tableViewLeftMargin + 5, y: yAxis, width: width, height: width)
        
        headerView.addSubview(image)
        
        let label = UILabel()
        label.text = headerInfo.sectionName
        label.textColor = .darkGray
        
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        
        label.frame = CGRect(x: tableViewLeftMargin + 15 + 15,
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
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if editMode {
//            return false
//        }
//
//        return true
//    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        selectionHaptic.selectionChanged()
        self.beginEditMode()

//        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//        self.selectedRows.append(indexPath)

        let size = 35

        let action = UIContextualAction(style: .destructive, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
            cell.rowSelected = true
            
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
            self.selectedRows.append(indexPath)
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
        swipeAction.performsFirstActionWithFullSwipe = false

        return swipeAction
    }
}
