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
    
    var quoteArray = [Quote]()
    
    var colorArray = ColorTheme.init().colorArray
    var colorCount: Int = 0
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var quoteTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quoteTableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil) , forCellReuseIdentifier: "QuoteCell")
        
        colorCount = colorArray.count
        
        configureTableView()
        
        loadQuotes()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if searchBar.text != "" {
            searchBar.text = ""
            
            loadQuotes()
        }
    }
    
    func loadQuotes(predicate: NSPredicate? = nil) {
        let request : NSFetchRequest<Quote> = Quote.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "addedOn", ascending: false)]
        
        if (predicate != nil) {
            request.predicate = predicate
        }
        
        do {
            quoteArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveContext() {
        do {
            try context.save()
            tableView.reloadData()
            
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func configureTableView() {
        quoteTableView.estimatedRowHeight = 500.0
        quoteTableView.rowHeight = UITableView.automaticDimension
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mod = indexPath.row % colorCount
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        
        let quote = quoteArray[indexPath.row]
        
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
        
//        cell.quoteHeader.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        cell.quoteBackground.backgroundColor = .white //colorArray[mod]
//        cell.quoteBackground.layer.masksToBounds = false
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        context.delete(quoteArray[indexPath.row])
        quoteArray.remove(at: indexPath.row)
        
        saveContext()
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

