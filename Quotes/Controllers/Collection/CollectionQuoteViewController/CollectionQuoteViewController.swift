//
//  CollectionQuoteViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 24/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class CollectionQuoteViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var quoteActionSheetService = QuoteActionSheetService()
    lazy var editQuoteService = EditQuoteService()
    lazy var moveCollectionService = MoveCollectionService()
    lazy var updateAppContextService = UpdateAppContextService()
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    lazy var quoteSectionArray = QuoteSections.init().quoteSections
    
    var colorArray = ColorTheme.init(alpha: 0.2).colorArray
    var colorCount: Int = 0
    
    //MARK: - IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    
//    @IBOutlet var quoteTableView: UITableView!
    
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
//        quoteTableView.delegate = self
//        quoteTableView.dataSource = self
        
        searchBar.delegate = self
        
        colorCount = colorArray.count
        
        configureTableView()
        
        if didSet {
            loadQuotes()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadQuotes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if searchBar.text != "" {
            searchBar.text = ""
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
        
        
        tableView.reloadData()
    }
    
    func configureTableView() {
        tableView.estimatedRowHeight = 500.0
        tableView.rowHeight = UITableView.automaticDimension
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
            
            loadQuotes()
            
            updateAppContext()
            
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func updateAppContext() {
        updateAppContextService.updateAppContext()
    }
}

extension CollectionQuoteViewController {
    //MARK: - TableView Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        if quoteSectionArray.count == 0 {
            tableView.setEmptyView()
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
        let width : CGFloat = 15
        
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
        
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title3)
        
        label.frame = CGRect(x: tableViewLeftMargin + 15 + 10,
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
        
        let quoteInfo = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        var pinIcon = "star-yellow"
        
        if quoteInfo.isPin == true {
            pinIcon = "unstar-yellow"
        }
        
        let pinAction = UIContextualAction(style: .normal, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            self.selectionHaptic.selectionChanged()
            
            print("pin quote")
            self.pinQuote(indexPath: indexPath)
            completionHandler(true)
        }
        
        let pinImage = UIGraphicsImageRenderer(size: CGSize(width: 25, height: 25)).image { _ in
            UIImage(named: pinIcon)?.draw(in: CGRect(x: 0, y: 0, width: 25, height: 25))
        }
        
        if let cgImageX =  pinImage.cgImage {
            pinAction.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale , orientation: .up)
        }
        
        pinAction.backgroundColor = .white
        
        return UISwipeActionsConfiguration(actions: [pinAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! QuoteTableViewCell
        
        let moreAction = UIContextualAction(style: .destructive, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            self.selectionHaptic.selectionChanged()
            
            print("more quote")
            self.showActionSheet(cell: cell)
            completionHandler(false)
        }
        
        let moreImage = UIGraphicsImageRenderer(size: CGSize(width: 25, height: 25)).image { _ in
            UIImage(named: "more-dark")?.draw(in: CGRect(x: 0, y: 0, width: 25, height: 25))
        }
        
        if let cgImageX = moreImage.cgImage {
            moreAction.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        
        moreAction.backgroundColor = .white
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            self.selectionHaptic.selectionChanged()
            
            print("delete quote")
            self.deleteQuote(indexPath: indexPath)
            completionHandler(true)
        }
        
        let trashImage = UIGraphicsImageRenderer(size: CGSize(width: 25, height: 25)).image { _ in
            UIImage(named: "trash-red")?.draw(in: CGRect(x: 0, y: 0, width: 25, height: 25))
        }
        
        if let cgImageX = trashImage.cgImage {
            deleteAction.image = ImageWithoutRender(cgImage: cgImageX, scale: UIScreen.main.nativeScale, orientation: .up)
        }
        
        deleteAction.backgroundColor = .white
        
        return UISwipeActionsConfiguration(actions: [deleteAction, moreAction])
    }
    
    func pinQuote(indexPath: IndexPath) {
        let updateQuote = self.quoteSectionArray[indexPath.section].quotes[indexPath.row]
        updateQuote.setValue(!updateQuote.isPin, forKey: "isPin")
        updateQuote.setValue(Date(), forKey: "updatedOn")
        
        saveContext()
        
//        loadQuotes()
    }
    
    func showActionSheet(cell: QuoteTableViewCell) {
        let quoteActionSheetVC = quoteActionSheetService.show(cell: cell)
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
}

extension CollectionQuoteViewController: QuoteActionSheetViewControllerDelegate {
    func handleDismissal() {
        self.navigationController?.view.alpha = 1
    }
    
    func handleEditQuote(cell: QuoteTableViewCell) {
        print("Edit Quote")
        let editQuoteVC = editQuoteService.show(cell: cell)
        editQuoteVC.delegate = self
        self.present(editQuoteVC, animated: true)
    }
    
    func handleMoveCollection(cell: QuoteTableViewCell) {
        print("Move Collection")
        let moveCollectionVC = moveCollectionService.show(cell: cell)
        self.present(moveCollectionVC, animated: true)
    }
    
    func handleShare(cell: QuoteTableViewCell) {
        var text = cell.quoteLabel.text
        if cell.authorLabel.text != "" {
            text = "\(text ?? "") \n- \(cell.authorLabel.text ?? "")"
        }
        
        let shareText = text ?? ""
        
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
}

extension CollectionQuoteViewController: EditQuoteViewControllerDelegate {
    func reloadQuote() {
        loadQuotes()
        updateAppContext()
    }
}
