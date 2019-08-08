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
    
    // MARK: - IBOutlet
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var quoteTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorCount = colorArray.count
        
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.loadQuotes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if searchBar.text != "" {
            searchBar.text = ""
        }
    }
    
    
    // MARK: - IBAction
    @IBAction func showCopyMenu(_ sender: UILongPressGestureRecognizer) {
        print("long pressed detected")
    }
    
    // MARK: - Functions
    func loadQuotes(predicate: NSPredicate? = nil) {
        print("loadQuotes")
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
        quoteTableView.estimatedRowHeight = 500.0
        quoteTableView.rowHeight = UITableView.automaticDimension
    }
    
    func saveContext() {
        do {
            try context.save()
            
            reloadQuote()
            
            updateAppContext()
            
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func updateAppContext() {
        updateAppContextService.updateAppContext()
    }
    
    func checkAndResignFirstResponder() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    func pinQuote(indexPath: IndexPath) {
        let updateQuote = self.quoteSectionArray[indexPath.section].quotes[indexPath.row]
        updateQuote.setValue(!updateQuote.isPin, forKey: "isPin")
        updateQuote.setValue(Date(), forKey: "updatedOn")
        
        saveContext()
    }
    
    func showActionSheet(cell: QuoteTableViewCell, objectId: NSManagedObjectID) {
        let quoteActionSheetVC = quoteActionSheetService.show(cell: cell, objectId: objectId)
        quoteActionSheetVC.delegate = self
        
        self.navigationController?.view.alpha = 0.6;
        self.present(quoteActionSheetVC, animated: true)
    }
    
    func deleteQuote(indexPath: IndexPath) {
        context.delete(quoteSectionArray[indexPath.section].quotes[indexPath.row])
        quoteSectionArray[indexPath.section].quotes.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        saveContext()
    }
    
    // MARK: - Unwind Segue
    @IBAction func backToQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier != nil else { return }
        
        checkAndResignFirstResponder()
        
        switch segue.identifier {
        case "goToAddQuoteView":
            print("Let's go to add a quote")
        default:
            print("unknown segue identifier")
            
        }
    }
}

// MARK: - UITableViewDelegate
extension QuoteViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if quoteSectionArray.count == 0 {
            if searchBar.text == "" {
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
        let mod = (indexPath.row + indexPath.section) % colorCount
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        
        let quote = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        
        cell.quote = quote
        cell.color = colorArray[mod]
        
        return cell
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
        
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        
        label.frame = CGRect(x: tableViewLeftMargin + 15 + 15,  // table margin left - image width - margin (image - label)
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
        
        var size = 35
        
        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
        let quote = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        
        let moreAction = UIContextualAction(style: .destructive, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            self.selectionHaptic.selectionChanged()
            
            self.showActionSheet(cell: cell, objectId: quote.objectID)
            completionHandler(false)
        }
        
        let moreImage = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
            UIImage(named: "more-dark")?.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
        
        if let cgImageX = moreImage.cgImage {
            moreAction.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        
        moreAction.backgroundColor = .white
        
        size = 30
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            self.selectionHaptic.selectionChanged()
            
            self.deleteQuote(indexPath: indexPath)
            completionHandler(true)
        }
        
        let trashImage = UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
            UIImage(named: "trash-red")?.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
        
        if let cgImageX = trashImage.cgImage {
            deleteAction.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        
        deleteAction.backgroundColor = .white
        
        return UISwipeActionsConfiguration(actions: [deleteAction, moreAction])
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
    
    func handleMoveCollection(cell: QuoteTableViewCell) {
        print("Move Collection")
        let moveCollectionVC = moveCollectionService.show(cell: cell)
        
        self.present(moveCollectionVC, animated: true)
    }
    
    func handleRemoveFromCollection(reload: Bool) {
        if reload {
            reloadQuote()
        }
    }
    
    func handleShare(cell: QuoteTableViewCell) {
        var text = cell.quoteLabel.text
        if cell.authorLabel.text != "" {
            text = "\(text ?? "") \n- \(cell.authorLabel.text ?? "")"
        }
        
        let vc = UIActivityViewController(activityItems: [text ?? ""], applicationActivities: [])
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
