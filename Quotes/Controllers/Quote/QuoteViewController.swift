//
//  QuoteViewController.swift
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
    
    lazy var editQuoteService = EditQuoteService()
    lazy var moveCollectionService = MoveCollectionService()
    lazy var updateAppContextService = UpdateAppContextService()
    lazy var reviewService = ReviewService.shared
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    lazy var quoteSectionArray = [QuoteSection]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var colorArray = ColorTheme.init(alpha: 0.2).colorArray
    var colorCount: Int = 0
    
    var editMode = false
    var selectedRows = [IndexPath]()
    
    // MARK: - IBOutlet
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var favouriteButton: UIBarButtonItem!
    @IBOutlet var copyButton: UIBarButtonItem!
    @IBOutlet var moveButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    
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

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        reloadQuote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        reloadQuote()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    // MARK: - IBAction
    @IBAction func cancelClicked(_ sender: Any) {
        endEditMode()
    }
    
    @IBAction func favouriteClicked(_ sender: Any) {

        selectionHaptic.selectionChanged()
        
        guard let quotes = getSelectedQuotes() else { return }
        
        var isPin = true
        if favouriteButton.title == "Favourite" {
            isPin = true
        } else {
            isPin = false
        }
        
        for i in quotes {
            i.setValue(isPin, forKey: "isPin")
            i.setValue(Date(), forKey: "updatedOn")
        }
        saveContext()

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
        
        self.navigationItem.rightBarButtonItems = [addButton]
        self.navigationController?.setToolbarHidden(true, animated: false)
   
        tableView.reloadData()
        
//        if quoteSectionArray.count > 0 {
//            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: true)
//        }
    }
    
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

// MARK: - EditQuoteViewControllerDelegate
extension QuoteViewController: EditQuoteViewControllerDelegate {
    func reloadQuote() {
        loadQuotes()
        updateAppContext()
    }
}

extension QuoteViewController: MoveCollectionViewControllerDelegate {
    func handleDismissal(endEditMode: Bool, reload: Bool) {
        if reload {
            loadQuotes()

            if searchController.searchBar.text != "" {
                searchController.isActive = false
            }
        }
        
        if endEditMode {
            self.endEditMode()
        }

    }
}
