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
    
    lazy var actionSheetService = ActionSheetService()
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    lazy var quoteSectionArray = QuoteSections.init().quoteSections
    
    var colorArray = ColorTheme.init(alpha: 0.2).colorArray
    var colorCount: Int = 0
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var quoteTableView: UITableView!
    
    var quoteSection: QuoteSection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorCount = colorArray.count
        
        configureTableView()
        //loadQuotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadQuotes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if searchBar.text != "" {
            searchBar.text = ""
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
    
    //MARK: - IBAction
    
    @IBAction func showCopyMenu(_ sender: UILongPressGestureRecognizer) {
        print("long pressed detected")
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
        headerView.backgroundColor = .white
        
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
        
        loadQuotes()
    }
    
    func showActionSheet(cell: QuoteTableViewCell) {
        let actionSheetVC = actionSheetService.show(cell: cell)
        
        present(actionSheetVC, animated: true, completion: nil)
    }
    
    func deleteQuote(indexPath: IndexPath) {
        context.delete(quoteSectionArray[indexPath.section].quotes[indexPath.row])
        quoteSectionArray[indexPath.section].quotes.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        saveContext()
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

class ImageWithoutRender: UIImage {
    override func withRenderingMode(_ renderingMode: UIImage.RenderingMode) -> UIImage {
        return self
    }
}
