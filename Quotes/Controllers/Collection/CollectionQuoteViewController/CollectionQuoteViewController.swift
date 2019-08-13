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
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var actionButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        colorCount = colorArray.count
        
        configureTableView()
        
        if didSet {
            loadQuotes()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadQuotes()
        
        self.navigationItem.rightBarButtonItems = [editButton]
        editMode = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if searchBar.text != "" {
            searchBar.text = ""
        }
    }
    
    // MARK: - IBAction
    @IBAction func actionClicked(_ sender: Any) {
        print("actionClicked")
        showActionSheet()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        setupEditMode(mode: "End Editing")
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
    
    func setupEditMode(mode: String) {
        selectedRows = [IndexPath]()
        
        if mode == "Begin Editing" {
            editMode = true
            self.navigationItem.rightBarButtonItems = [cancelButton, actionButton]
            
        } else if mode == "End Editing" {
            editMode = false
            self.navigationItem.rightBarButtonItems = [editButton]
            
        } else {
            editMode = false
            print("unhandled mode")
        }
        
        tableView.reloadData()
        
//        for i in 0 ... (quoteSectionArray.count - 1) {
//            for j in 0 ... (quoteSectionArray[i].quotes.count - 1)
//            {
//                let cell = tableView.cellForRow(at: IndexPath(row: j, section: i)) as! QuoteTableViewCell
//
//                selectedRows = [IndexPath]()
//
//                cell.rowSelected = false
//                cell.rowSelectedImage.isHidden = !editMode
//            }
//        }
    }
    
    func checkAndResignFirstResponder() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
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
            if searchBar.text == "" {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
        
        if editMode {
            selectedRows.append(indexPath)
            
            cell.rowSelected = true
        } else {
            tableView.beginUpdates()
            cell.quoteLabel.numberOfLines = 0
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
        
        if editMode {
            guard let index = selectedRows.firstIndex(of:indexPath) else { return }
            selectedRows.remove(at: index)
            
            cell.rowSelected = false
        } else {
            tableView.beginUpdates()
            cell.quoteLabel.numberOfLines = 2
            tableView.endUpdates()
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
        
        let size = 35
        
        let moreAction = UIContextualAction(style: .destructive, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
//            let cell = self.tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
            
            self.selectionHaptic.selectionChanged()
            self.setupEditMode(mode: "Begin Editing")
            
//            self.selectedRows.append(indexPath)
//            cell.rowSelected = true
            
            completionHandler(false)
        }
        
        let moreImage = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
            UIImage(named: "more-dark")?.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
        
        if let cgImageX = moreImage.cgImage {
            moreAction.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        
        moreAction.backgroundColor = .white
        
        let editAction = UIContextualAction(style: .destructive, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            self.selectionHaptic.selectionChanged()
            self.editQuote(indexPath: indexPath)
            
            completionHandler(true)
        }
        
        let editImage = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
            UIImage(named: "pencil-blue")?.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
        
        if let cgImageX = editImage.cgImage {
            editAction.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        
        editAction.backgroundColor = .white
        
        return UISwipeActionsConfiguration(actions: [moreAction, editAction])
    }
    
    func pinQuote(indexPath: IndexPath) {
        let updateQuote = self.quoteSectionArray[indexPath.section].quotes[indexPath.row]
        updateQuote.setValue(!updateQuote.isPin, forKey: "isPin")
        updateQuote.setValue(Date(), forKey: "updatedOn")
        
        saveContext()
    }
    
    func showActionSheet() {
        if selectedRows.count > 0 {
            var quotes = [Quote]()
            
            print(selectedRows)
            
            for i in selectedRows {
                let quote = quoteSectionArray[i.section].quotes[i.row]
                quotes.append(quote)
            }
            
            let quoteActionSheetVC = quoteActionSheetService.show(quotes: quotes, collection: collection)
            quoteActionSheetVC.delegate = self
            
            self.navigationController?.view.alpha = 0.6;
            self.present(quoteActionSheetVC, animated: true)
        }
    }
    
    func deleteQuote(indexPath: IndexPath) {
        context.delete(quoteSectionArray[indexPath.section].quotes[indexPath.row])
        quoteSectionArray[indexPath.section].quotes.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        saveContext()
    }
    
    func editQuote(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
        let objectId = quoteSectionArray[indexPath.section].quotes[indexPath.row].objectID
        
        let editQuoteVC = editQuoteService.show(cell: cell, objectId: objectId)
        editQuoteVC.delegate = self
        
        self.present(editQuoteVC, animated: true)
    }
}

// MARK: - QuoteActionSheetViewControllerDelegate
extension CollectionQuoteViewController: QuoteActionSheetViewControllerDelegate {
    func handleDismissal() {
        UIView.animate(withDuration: 0.1) {
            self.navigationController?.view.alpha = 1
            
            self.setupEditMode(mode: "End Editing")
        }
    }
    
    func handleEditQuote(cell: QuoteTableViewCell, objectId: NSManagedObjectID) {
        let editQuoteVC = editQuoteService.show(cell: cell, objectId: objectId)
        editQuoteVC.delegate = self
        
        self.present(editQuoteVC, animated: true)
    }
    
    func handleMoveCollection(quotes: [Quote]) {
        print("Move Collection")
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
extension CollectionQuoteViewController: EditQuoteViewControllerDelegate {
    func reloadQuote() {
        loadQuotes()
        updateAppContext()
    }
}
