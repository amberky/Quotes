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
    
    let blueColor = UIColor.rgb(red: 85, green: 85, blue: 85)
    
    var feedbackGenerator : UISelectionFeedbackGenerator? = nil
    
    var quoteArray = [[Quote]]()
    
    var pinArray = [Quote]()
    var unpinArray = [Quote]()
    
    var num: Int = 0
    var colorArray = ColorTheme.init().colorArray
    var colorCount: Int = 0
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var quoteTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil) , forCellReuseIdentifier: "QuoteCell")
        colorCount = colorArray.count
        
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadQuotes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if searchBar.text != "" {
            searchBar.text = ""
            
            loadQuotes()
        }
    }
    
    func loadQuotes(predicate: NSPredicate? = nil) {
        num = 0
        quoteArray = [[Quote]]()
        
        let sort = [NSSortDescriptor(key: "addedOn", ascending: false)]
        
        let pinRequest : NSFetchRequest<Quote> = Quote.fetchRequest()
        pinRequest.sortDescriptors = sort
        
        let request : NSFetchRequest<Quote> = Quote.fetchRequest()
        request.sortDescriptors = sort
        
        let pinPredicate = NSPredicate.init(format: "isPin == %@", NSNumber(value: true))
        let unpinPredicate = NSPredicate.init(format: "isPin == %@", NSNumber(value: false))
        
        if (predicate != nil) {
            pinRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pinPredicate, predicate!])
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [unpinPredicate, predicate!])
            
        } else {
            pinRequest.predicate = pinPredicate
            request.predicate = unpinPredicate
        }
        
        do {
            pinArray = try context.fetch(pinRequest)
            unpinArray = try context.fetch(request)
            
            //if pinArray.count > 0 {
            quoteArray.append(pinArray)
            //}
            
            //if unpinArray.count > 0 {
            quoteArray.append(unpinArray)
            //}
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveContext(retrieveDataFromContext: Bool) {
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
        return quoteArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let imageName = section == 0 ? "pin-dark" : "quote-dark"
        let image = UIImageView(image: UIImage.init(named: imageName))
        image.frame = CGRect(x: tableView.separatorInset.left + 5,
                             y: (self.tableView.sectionHeaderHeight - 15) / 2,
                             width: 15,
                             height: 15)
        
        headerView.addSubview(image)
        
        let label = UILabel()
        label.text = section == 0 ? "PINNED QUOTES" : "QUOTES"
        label.textColor = .darkGray
        label.font = UIFont.boldSystemFont(ofSize: 15)
        
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.callout)
        
        label.frame = CGRect(x: tableView.separatorInset.left + 15 + 10,
                             // table margin left - image width - 10 margin (image - label)
            y: (self.tableView.sectionHeaderHeight - 15) / 2,
            width: tableView.frame.width - tableView.separatorInset.left - tableView.separatorInset.left - 20 - 10,
            height: 15)
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        if section == 0 && pinArray.count > 0 && unpinArray.count > 0 {
            
            let separator = UIView()
            separator.frame = CGRect(x: 0,
                                     y: self.tableView.sectionHeaderHeight / 2,
                                     width: tableView.frame.width,
                                     height: 2)
            
            if pinArray.count != 0 && unpinArray.count != 0 {
                separator.backgroundColor = UIColor.rgb(red: 238, green: 238, blue: 238)
            } else {
                separator.backgroundColor = .clear
            }
            
            footerView.addSubview(separator)
        }
        
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && pinArray.count > 0 {
            return self.tableView.sectionHeaderHeight
        } else if section == 1 && unpinArray.count > 0 {
            return self.tableView.sectionHeaderHeight
        } else {
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 0 && pinArray.count > 0) {
            return self.tableView.sectionHeaderHeight
        } else {
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mod = num % colorCount
        num += 1
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        
        let quote = quoteArray[indexPath.section][indexPath.row]
        
        cell.delegate = self
        cell.quoteLabel.text = quote.quote
        cell.authorLabel.text = "\(quote.author ?? "")"
        
        if quote.author != "" {
            cell.authorLabel.topAnchor.constraint(equalTo: cell.quoteLabel.bottomAnchor, constant: 10).isActive = true
        } else {
            cell.authorLabel.topAnchor.constraint(equalTo: cell.quoteLabel.bottomAnchor, constant: 0).isActive = true
        }
        
        cell.quoteHeader.backgroundColor = colorArray[mod]
        
        cell.quoteHeader.clipsToBounds = true
        cell.fakeQuoteHeader.backgroundColor = colorArray[mod]
        
        cell.quoteBackground.backgroundColor = .white
        cell.quoteBackground.layer.shadowOpacity = 0.2
        cell.quoteBackground.layer.shadowRadius = 2
        cell.quoteBackground.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.quoteBackground.layer.shadowColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
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

extension QuoteViewController: QuoteTableViewCellDelegate {
    func longPressed(cell: QuoteTableViewCell) {
        print("long pressed")
        
        if let indexPath = tableView.indexPath(for: cell)
        {
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let editAction = UIAlertAction.init(title: "Edit", style: .default) { (action) in
                print("Edit")
            }
            alert.addAction(editAction)
            
            let deleteAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
                print("Delete")
                
                self.context.delete(self.quoteArray[indexPath.section][indexPath.row])
                
                self.quoteArray[indexPath.section].remove(at: indexPath.row)
                if indexPath.section == 0 {
                    self.pinArray.remove(at: indexPath.row)
                } else {
                    self.unpinArray.remove(at: indexPath.row)
                }
                
                self.quoteTableView.deleteRows(at: [indexPath], with: .fade)
                self.quoteTableView.reloadSections(IndexSet(integersIn: 0...1), with: .fade)
                
                self.saveContext(retrieveDataFromContext: false)
            }
                        
            alert.addAction(deleteAction)
            
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
                print("Cancel")
            }
            alert.addAction(cancelAction)
            alert.view.tintColor = UIColor.rgb(red: 93, green: 117, blue: 153);
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func doubleTapped(cell: QuoteTableViewCell) {
        print("double tapped")
        
        if let indexPath = tableView.indexPath(for: cell) {
            let updateQuote = self.quoteArray[indexPath.section][indexPath.row]
            updateQuote.setValue(!updateQuote.isPin, forKey: "isPin")
            
            if updateQuote.isPin == true {
                pinArray.append(updateQuote)
                unpinArray.remove(at: indexPath.row)
            } else {
                unpinArray.append(updateQuote)
                pinArray.remove(at: indexPath.row)
            }
            
            saveContext(retrieveDataFromContext: true)
            
            num = 0
            pinArray = pinArray.sorted { (a, b) -> Bool in
                (a.addedOn ?? Date()).compare(b.addedOn ?? Date()) == .orderedDescending
            }
            
            unpinArray = unpinArray.sorted { (a, b) -> Bool in
                (a.addedOn ?? Date()).compare(b.addedOn ?? Date()) == .orderedDescending
            }
            
            quoteArray = [pinArray, unpinArray]
            
            tableView.reloadSections(IndexSet(integersIn: 0...1), with: .automatic)
            
        }
    }
}

//MARK: - Search Bar methods
extension QuoteViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchQuote(searchBar: searchBar, hideKeyboard: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuote(searchBar: searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchQuote(searchBar: searchBar, hideKeyboard: true)
    }
    
    func searchQuote(searchBar : UISearchBar, hideKeyboard : Bool = false) {
        if searchBar.text?.count == 0 {
            loadQuotes()
        }
        else {
            let predicate = NSPredicate(format: "quote CONTAINS[cd] %@", searchBar.text!)
            
            loadQuotes(predicate: predicate)
        }
        
        if hideKeyboard {
            //Dispatch Queue assign the task to different threads
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
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
