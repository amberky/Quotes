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
    
    var quoteSectionArray = QuoteSections.init().quoteSections
    
    var colorArray = ColorTheme.init().colorArray
    var colorCount: Int = 0
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var quoteTableView: UITableView!
    
    var quoteSection: QuoteSection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil) , forCellReuseIdentifier: "QuoteCell")
        
        tableView.dragInteractionEnabled = true
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
        quoteSectionArray = QuoteSections.init().quoteSections
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        
        let quote = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        
        cell.quote = quote

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return quoteSectionArray[section].sectionName
    }
    
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//
//        let movedObject = quoteSectionArray[sourceIndexPath.section].quotes[sourceIndexPath.row]
//         quoteSectionArray[destinationIndexPath.section].quotes.insert(movedObject, at: destinationIndexPath.row)
//        quoteSectionArray[sourceIndexPath.section].quotes.remove(at: sourceIndexPath.row)
//
//        tableView.reloadData()
//    }
    
//    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        if sourceIndexPath.section != proposedDestinationIndexPath.section {
//            return sourceIndexPath
//        } else {
//            return proposedDestinationIndexPath
//        }
//    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    //MARK: - unwind Segue
    @IBAction func backToQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier ?? "")
        checkAndResignFirstResponder()
    }
    
    func checkAndResignFirstResponder() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
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
