//
//  CollectionQuoteViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 24/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import CoreData

class CollectionQuoteViewController: UITableViewController {
    
    // MARK: - Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var quoteActionSheetService = QuoteActionSheetService()
    lazy var editQuoteService = EditQuoteService()
    lazy var moveCollectionService = MoveCollectionService()
    lazy var updateAppContextService = UpdateAppContextService()
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    lazy var quoteSectionArray = QuoteSections.init().quoteSections
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var colorArray = ColorTheme.init(alpha: 0.2).colorArray
    var colorCount: Int = 0
    
    var editMode = false
    var selectedRows = [IndexPath]()
    
    var didSet: Bool = false
    var selectedCollection: CollectionModel? {
        didSet {
            print("didSet selectedCollection")
            didSet = true
            
            setTitle()
        }
    }
    
    var collection: Collection? {
        didSet {
            print("didSet collection")
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var favouriteButton: UIBarButtonItem!
    @IBOutlet var copyButton: UIBarButtonItem!
    @IBOutlet var moveButton: UIBarButtonItem!
    @IBOutlet var trashButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorCount = colorArray.count
        
        configureTableView()
        
        if didSet {
            loadQuotes()
        }
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.toolbar.barTintColor = UIColor.mainBlue()
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = UIColor.mainBlue()
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
//        if #available(iOS 13.0, *) {
//            copyButton.image = UIImage.init(systemName: "doc.on.doc")
//            favouriteButton.image = UIImage.init(systemName: "star")
//            moveButton.image = UIImage.init(systemName: "folder")
//            trashButton.image = UIImage.init(systemName: "trash")
//            shareButton.image = UIImage.init(systemName: "square.and.arrow.up")
//        } else {
//            favouriteButton.image = nil
//            moveButton.image = nil
//            copyButton.image = nil
//            trashButton.image = nil
//            shareButton.image = nil
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadQuotes()
        
        self.navigationItem.rightBarButtonItems = [editButton]
        editMode = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        if searchBar.text != "" {
//            searchBar.text = ""
//        }
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
    func setTitle() {
        self.title = selectedCollection?.name
        
        if selectedCollection?.isAll == true {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            let request: NSFetchRequest<Collection> = Collection.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", selectedCollection?.name ?? "")
            
            do {
                if let collectionContext = try self.context.fetch(request) as [NSManagedObject]?, collectionContext.first != nil {
                    collection = collectionContext.first as? Collection
                }
            } catch {
                print("Error in fetching collection \(error)")
            }
        }
    }
    
    func loadQuotes(predicate: NSPredicate? = nil) {
        if selectedCollection?.isAll == false {
            quoteSectionArray = QuoteSections.init(collection: selectedCollection?.name, customPredicate: predicate).quoteSections
        } else {
            quoteSectionArray = QuoteSections.init(customPredicate: predicate).quoteSections
        }
        
        
        tableView.reloadData()
    }
    
    func configureTableView() {
        tableView.allowsMultipleSelection = true
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
        
        self.navigationItem.rightBarButtonItems = [editButton]
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        tableView.reloadData()
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
        //        if searchBar.isFirstResponder {
        //            searchBar.resignFirstResponder()
        //        }
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
    @IBAction func backToCollectionQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
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
}

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

// MARK: - EditQuoteViewControllerDelegate
extension CollectionQuoteViewController: EditQuoteViewControllerDelegate {
    func reloadQuote() {
        loadQuotes()
        updateAppContext()
    }
}

extension CollectionQuoteViewController: MoveCollectionViewControllerDelegate {
    func handleDismissal(endEditMode: Bool) {
        if endEditMode {
            self.endEditMode()
        }
    }
}
