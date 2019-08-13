//
//  ViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 21/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import CoreData

class QuoteViewController: UITableViewController {
    
    // MARK: Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var quoteActionSheetService = QuoteActionSheetService()
    lazy var editQuoteService = EditQuoteService()
    lazy var moveCollectionService = MoveCollectionService()
    lazy var updateAppContextService = UpdateAppContextService()
    lazy var reviewService = ReviewService.shared
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    lazy var quoteSectionArray = QuoteSections.init().quoteSections
    
    var colorArray = ColorTheme.init(alpha: 0.2).colorArray
    var colorCount: Int = 0
    
    var editMode = false
    var selectedRows = [IndexPath]()
    
    
    // MARK: - IBOutlet
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var actionButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        colorCount = colorArray.count
        
        configureTableView()
        
        self.navigationItem.rightBarButtonItems = [addButton]
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.toolbar.barTintColor = UIColor.mainBlue()
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = UIColor.mainBlue()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadQuotes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    
    // MARK: - IBAction
    @IBAction func actionClicked(_ sender: Any) {
        showActionSheet()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        endEditMode()
    }
    
    @IBAction func copyClicked(_ sender: Any) {
        guard let quotes = getSelectedQuotes() else { return }
        
        selectionHaptic.selectionChanged()
        let text = concatText(quotes: quotes)
        
        let copy = UIPasteboard.general
        copy.string = text
        
        endEditMode()
    }
    
    
    @IBAction func moveClicked(_ sender: Any) {
        guard let quotes = getSelectedQuotes() else { return }
        
        selectionHaptic.selectionChanged()
        
        let moveCollectionVC = moveCollectionService.show(quotes: quotes)
        moveCollectionVC.delegate = self
        
        self.present(moveCollectionVC, animated: true)
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        guard let quotes = getSelectedQuotes() else { return }
        
        selectionHaptic.selectionChanged()
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deleteQuote(quotes: quotes)
            self.endEditMode()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = UIColor.mainBlue()
        
        present(alert, animated: true)
    }
    
    
    @IBAction func shareClicked(_ sender: Any) {
        guard let quotes = getSelectedQuotes() else { return }
        
        selectionHaptic.selectionChanged()
        let text = concatText(quotes: quotes)
        
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
        
        present(vc, animated: true)
    }
    
    // MARK: - Functions
    func getSelectedQuotes() -> [Quote]? {
        if selectedRows.count > 0 {
            var quotes = [Quote]()
            
            for i in selectedRows {
                let quote = quoteSectionArray[i.section].quotes[i.row]
                quotes.append(quote)
            }
            
            return quotes
        }
        
        return nil
    }
    
    func concatText(quotes: [Quote]) -> String {
        guard quotes.count > 0 else { return "" }
        
        var str = ""
        
        for i in quotes {
            if i.quote != nil {
                var text = i.quote
                if i.author != "" {
                    text = "\(text ?? "")\n- \(i.author ?? "")"
                }
                
                str = "\(str)\n\n\(text ?? "")"
            }
        }
        
        return str
    }
    
    func loadQuotes(predicate: NSPredicate? = nil) {
        quoteSectionArray = QuoteSections.init(customPredicate: predicate).quoteSections
        
        tableView.reloadData()
        
        if quoteSectionArray.count > 0, (quoteSectionArray.first?.quotes.count ?? 0) > 1 {
            
            let deadline = DispatchTime.now() + .seconds(1)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.reviewService.requestReview()
            }
        }
    }
    
    func configureTableView() {
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.estimatedRowHeight = 500.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func beginEditMode() {
        selectedRows = [IndexPath]()
        editMode = true
        
        self.navigationItem.rightBarButtonItems = [cancelButton]
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        tableView.reloadData()
    }
    
    func endEditMode() {
        selectedRows = [IndexPath]()
        
        editMode = false
        selectedRows = [IndexPath]()
        
        self.navigationItem.rightBarButtonItems = [addButton]
        self.navigationController?.setToolbarHidden(true, animated: false)
   
        tableView.reloadData()
    }
    
    func saveContext() {
        do {
            try context.save()
            
            loadQuotes()
            
            updateAppContext()
            
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func updateAppContext() {
        updateAppContextService.updateAppContext()
    }
    
    func checkAndResignFirstResponder() {
//        if searchBar.isFirstResponder {
//            searchBar.resignFirstResponder()
//        }
    }
    
    func showActionSheet() {
        if selectedRows.count > 0 {
            var quotes = [Quote]()
            
            for i in selectedRows {
                let quote = quoteSectionArray[i.section].quotes[i.row]
                quotes.append(quote)
            }
            
            let quoteActionSheetVC = quoteActionSheetService.show(quotes: quotes, collection: nil)
            quoteActionSheetVC.delegate = self
            
            self.navigationController?.view.alpha = 0.6;
            self.present(quoteActionSheetVC, animated: true)
        }
    }
    
    func pinQuote(indexPath: IndexPath) {
        let updateQuote = self.quoteSectionArray[indexPath.section].quotes[indexPath.row]
        updateQuote.setValue(!updateQuote.isPin, forKey: "isPin")
        updateQuote.setValue(Date(), forKey: "updatedOn")
        
        saveContext()
    }
    
    func deleteQuote(quotes: [Quote]) {
        for q in quotes {
            context.delete(q)
        }

        saveContext()
        loadQuotes()
        endEditMode()
    }
    
    func editQuote(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
        let objectId = quoteSectionArray[indexPath.section].quotes[indexPath.row].objectID
        
        let editQuoteVC = editQuoteService.show(cell: cell, objectId: objectId)
        editQuoteVC.delegate = self
        
        self.present(editQuoteVC, animated: true)
    }
    
    // MARK: - Unwind Segue
    @IBAction func backToQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier != nil else { return }
        
        checkAndResignFirstResponder()
        if editMode {
            endEditMode()
        }
        
        switch segue.identifier {
        case "goToAddQuoteView":
            print("Let's go to add a quote")
        default:
            print("unknown segue identifier")
            
        }
    }
}

// MARK: - QuoteActionSheetViewControllerDelegate
extension QuoteViewController: QuoteActionSheetViewControllerDelegate {
    func handleDismissal() {
        UIView.animate(withDuration: 0.1) {
            self.navigationController?.view.alpha = 1
        }
    }
    
    func handleEditQuote(cell: QuoteTableViewCell, objectId: NSManagedObjectID) {
        let editQuoteVC = editQuoteService.show(cell: cell, objectId: objectId)
        editQuoteVC.delegate = self
        
        self.present(editQuoteVC, animated: true)
    }
    
    func handleMoveCollection(quotes: [Quote]) {
        let moveCollectionVC = moveCollectionService.show(quotes: quotes)
        
        self.present(moveCollectionVC, animated: true)
    }
    
    func handleRemoveFromCollection(reload: Bool) {
        if reload {
            reloadQuote()
        }
    }
    
    func handleShare(text: String) {
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - EditQuoteViewControllerDelegate
extension QuoteViewController: EditQuoteViewControllerDelegate {
    func reloadQuote() {
        loadQuotes()
        updateAppContext()
    }
}

extension QuoteViewController: MoveCollectionViewControllerDelegate {
    func handleDismissal(endEditMode: Bool) {
        if endEditMode {
            self.endEditMode()
        }
    }
}
