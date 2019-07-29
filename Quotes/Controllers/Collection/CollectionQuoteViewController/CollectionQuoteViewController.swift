//
//  CollectionQuoteViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 24/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class CollectionQuoteViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    var quoteSectionArray = QuoteSections.init().quoteSections
    
    var colorArray = ColorTheme.init(alpha: 0.2).colorArray
    var colorCount: Int = 0
    
    //MARK: - IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var quoteTableView: UITableView!
    
    var didSet: Bool = false
    var selectedCollection: CollectionModel? {
        didSet {
            print("didSet")
            didSet = true
            
            setTitle()
            //loadQuotes()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        quoteTableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil) , forCellReuseIdentifier: "QuoteCell")
//
        quoteTableView.delegate = self
        quoteTableView.dataSource = self
        quoteTableView.dragInteractionEnabled = true
        quoteTableView.dragDelegate = self
        quoteTableView.dropDelegate = self
        
        searchBar.delegate = self
        
        colorCount = colorArray.count
        
        if didSet {
            loadQuotes()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if searchBar.text != "" {
            searchBar.text = ""
            
            loadQuotes()
        }
    }
    
    func setTitle() {
        self.title = selectedCollection?.name
        
        if selectedCollection?.isAll == true {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func loadQuotes(predicate: NSPredicate? = nil) {
        if selectedCollection?.isAll == false {
            quoteSectionArray = QuoteSections.init(collection: selectedCollection?.name, customPredicate: predicate).quoteSections
        } else {
            quoteSectionArray = QuoteSections.init(customPredicate: predicate).quoteSections
        }
        
        
        quoteTableView.reloadData()
    }
    
    
    //MARK: - unwindSegue
    @IBAction func backToCategoryQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        checkAndResignFirstResponder()
        
        switch identifier {
        case "goToEditCollectionView":
            print("Let's go to edit a collection")
            
            let destination = segue.destination as! EditCollectionViewController
            destination.selectedCollection = selectedCollection
        default:
            print("unknown segue identifier")
        }
    }
    
    func checkAndResignFirstResponder() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving data from context \(error)")
        }
    }
}

extension CollectionQuoteViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: - TableView Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return quoteSectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteSectionArray[section].quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mod = (indexPath.row + indexPath.section) % colorCount
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        
        let quote = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        
        cell.quote = quote
        cell.color = colorArray[mod]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return quoteSectionArray[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = quoteSectionArray[sourceIndexPath.section].quotes[sourceIndexPath.row]
        print(movedObject)
        
        quoteSectionArray[sourceIndexPath.section].quotes.remove(at: sourceIndexPath.row)
        quoteSectionArray[destinationIndexPath.section].quotes.insert(movedObject, at: destinationIndexPath.row)
        
        let queue = DispatchQueue(label: "saveOrdering", qos: .userInitiated)
        queue.async {
            self.saveOrdering()
        }
    }
    
    func saveOrdering() {
        for i in quoteSectionArray {
            for (index, item) in i.quotes.enumerated() {
                item.orderIndex = Int64(index)
            }
        }
        
        saveContext()
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.beginUpdates()
        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
        
        if cell.quoteLabel.numberOfLines == 2 {
            cell.quoteLabel.numberOfLines = 0
        } else {
            cell.quoteLabel.numberOfLines = 2
        }
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let headerInfo = quoteSectionArray[section]
        
        let imageName = headerInfo.sectionIcon
        let image = UIImageView(image: UIImage.init(named: imageName))
        image.frame = CGRect(x: tableView.separatorInset.left + 5,
                             y: (tableView.sectionHeaderHeight - 15) / 2,
                             width: 15,
                             height: 15)
        
        headerView.addSubview(image)
        
        let label = UILabel()
        label.text = headerInfo.sectionName
        label.textColor = .darkGray
        label.font = UIFont.boldSystemFont(ofSize: 15)
        
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.callout)
        
        label.frame = CGRect(x: tableView.separatorInset.left + 15 + 15,
                             // table margin left - image width - 15 margin (image - label)
            y: (tableView.sectionHeaderHeight - 15) / 2,
            width: tableView.frame.width - tableView.separatorInset.left - tableView.separatorInset.left - 20 - 10,
            height: 15)
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if quoteSectionArray[section].quotes.count == 0 {
            return 0.0
        } else {
            return tableView.sectionHeaderHeight
        }
    }
}


//extension CollectionQuoteViewController: QuoteTableViewCellDelegate {
//    func longPressed(cell: QuoteTableViewCell) {
//        print("long pressed")
//        
//        if let indexPath = quoteTableView.indexPath(for: cell)
//        {
//            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
//            
//            let editAction = UIAlertAction.init(title: "Edit", style: .default) { (action) in
//                print("Edit")
//            }
//            alert.addAction(editAction)
//            
//            let deleteAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
//                print("Delete")
//                
//                self.context.delete(self.quoteArray[indexPath.section][indexPath.row])
//                self.quoteArray[indexPath.section].remove(at: indexPath.row)
//                
//                if indexPath.section == 0 {
//                    self.pinArray.remove(at: indexPath.row)
//                } else {
//                    self.unpinArray.remove(at: indexPath.row)
//                }
//                
//                self.quoteTableView.deleteRows(at: [indexPath], with: .fade)
//                self.quoteTableView.reloadSections(IndexSet(integersIn: 0...1), with: .fade)
//                
//                
//                self.saveContext()
//            }
//            alert.addAction(deleteAction)
//            
//            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
//                print("Cancel")
//            }
//            alert.addAction(cancelAction)
//            alert.view.tintColor = UIColor.rgb(red: 93, green: 117, blue: 153);
//            
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//    
//    func doubleTapped(cell: QuoteTableViewCell) {
//        print("double tapped")
//        
//        if let indexPath = quoteTableView.indexPath(for: cell) {
//            let updateQuote = self.quoteArray[indexPath.section][indexPath.row]
//            updateQuote.setValue(!updateQuote.isPin, forKey: "isPin")
//            
//            if updateQuote.isPin == true {
//                pinArray.append(updateQuote)
//                unpinArray.remove(at: indexPath.row)
//            } else {
//                unpinArray.append(updateQuote)
//                pinArray.remove(at: indexPath.row)
//            }
//            
//            self.saveContext()
//            
//            num = 0
//            pinArray = pinArray.sorted { (a, b) -> Bool in
//                (a.addedOn ?? Date()).compare(b.addedOn ?? Date()) == .orderedDescending
//            }
//            
//            unpinArray = unpinArray.sorted { (a, b) -> Bool in
//                (a.addedOn ?? Date()).compare(b.addedOn ?? Date()) == .orderedDescending
//            }
//            
//            quoteArray = [pinArray, unpinArray]
//            
//            quoteTableView.reloadSections(IndexSet(integersIn: 0...1), with: .automatic)
//        }
//    }
//    
//}
