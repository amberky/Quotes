//
//  ViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 21/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class QuoteViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let selectionFeedback = UISelectionFeedbackGenerator()
    
    var quoteSectionArray = QuoteSections.init().quoteSections
    
    var colorArray = ColorTheme.init(alpha: 0.2).colorArray
    var colorCount: Int = 0
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var quoteTableView: UITableView!
    
    var quoteSection: QuoteSection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dragInteractionEnabled = false
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        colorCount = colorArray.count
        
        configureTableView()
        loadQuotes()
    }

    override func viewDidDisappear(_ animated: Bool) {
        if searchBar.text != "" {
            let queue = DispatchQueue(label: "loadQuotes", qos: .userInitiated)
            queue.async {
                self.searchBar.text = ""
                self.loadQuotes()
            }
        }
    }
    
    func loadQuotes(predicate: NSPredicate? = nil) {
        quoteSectionArray = QuoteSections.init(customPredicate: predicate).quoteSections
        
        tableView.reloadData()
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func configureTableView() {
        quoteTableView.estimatedRowHeight = 500.0
        quoteTableView.rowHeight = UITableView.automaticDimension
    }
    
    //MARK: - TableView Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return quoteSectionArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteSectionArray[section].quotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mod = (indexPath.row + indexPath.section) % colorCount
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        
        let quote = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        
        cell.quote = quote
        cell.color = colorArray[mod]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return quoteSectionArray[section].sectionName
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.beginUpdates()
        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell

        if cell.quoteLabel.numberOfLines == 2 {
            cell.quoteLabel.numberOfLines = 0
        } else {
            cell.quoteLabel.numberOfLines = 2
        }
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if quoteSectionArray[section].quotes.count == 0 {
            return 0.0
        } else {
            return tableView.sectionHeaderHeight
        }
    }
    
    //MARK: - unwind Segue
    @IBAction func backToQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier != nil else { return }
        
        checkAndResignFirstResponder()
        
        switch segue.identifier {
        case "goToAddQuoteView":
            // Set quoteCount to unpin quotes count
            let destination = segue.destination as! AddQuoteViewController
            destination.quoteCount = quoteSectionArray[1].quotes.count
            
        default:
            print("unknown segue identifier")
            
        }
    }
    
    func checkAndResignFirstResponder() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

extension UIImage {
    func imageWithSize(scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
