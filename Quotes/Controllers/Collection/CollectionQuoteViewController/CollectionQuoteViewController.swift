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
    
    lazy var actionSheetService = ActionSheetService()
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    lazy var quoteSectionArray = QuoteSections.init().quoteSections
    
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
        
        
        quoteTableView.reloadData()
    }
    
    func configureTableView() {
        quoteTableView.estimatedRowHeight = 500.0
        quoteTableView.rowHeight = UITableView.automaticDimension
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
        
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        
        label.frame = CGRect(x: tableView.separatorInset.left + 15 + 10,
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        selectionHaptic.prepare()
        
        let quoteInfo = quoteSectionArray[indexPath.section].quotes[indexPath.row]
        var pinIcon = "pin-orange"
        
        if quoteInfo.isPin == true {
            pinIcon = "unpin-orange"
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
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
        
        loadQuotes()
    }
    
    func showActionSheet(cell: QuoteTableViewCell) {
        self.navigationController?.view.alpha = 0.6;
        
        let actionSheetVC = actionSheetService.show(cell: cell)
        actionSheetVC.delegate = self
        
        self.present(actionSheetVC, animated: true)
    }
    
    func deleteQuote(indexPath: IndexPath) {
        context.delete(quoteSectionArray[indexPath.section].quotes[indexPath.row])
        quoteSectionArray[indexPath.section].quotes.remove(at: indexPath.row)
        
        quoteTableView.deleteRows(at: [indexPath], with: .fade)
        
        saveContext()
    }
}

extension CollectionQuoteViewController: ActionSheetViewControllerDelegate {
    func handleDismissal() {
        self.navigationController?.view.alpha = 1
    }
}
