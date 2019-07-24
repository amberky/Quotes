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
    
    var colorArray = [UIColor]()
    var quotesArray = [Quote]()
    var colorCount: Int = 0
    
    @IBOutlet var quoteTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  quoteTableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil) , forCellReuseIdentifier: "QuoteCell")
        // quoteTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        
        setupColors()
        
        configureTableView()
        
        loadQuotes()
    }
    
    func loadQuotes(with request: NSFetchRequest<Quote> = Quote.fetchRequest(), predicate: NSPredicate? = nil) {
        
        request.sortDescriptors = [NSSortDescriptor(key: "addedOn", ascending: false)]
        
        if (predicate != nil) {
            request.predicate = predicate
        }
        
        do {
            quotesArray = try context.fetch(request)
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mod = indexPath.row % colorCount
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let quote = quotesArray[indexPath.row]
        
        cell.quoteLabel.text = quote.quote
        cell.authorLabel.text = "\(quote.author ?? "")"
        
        if quote.author != "" {
            cell.authorLabel.topAnchor.constraint(equalTo: cell.quoteLabel.bottomAnchor, constant: 10).isActive = true
        } else {
            cell.authorLabel.topAnchor.constraint(equalTo: cell.quoteLabel.bottomAnchor, constant: 0).isActive = true
        }
        
        cell.quoteBackground.backgroundColor = colorArray[mod]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotesArray.count
    }
    
    //MARK: - unwind Segue
    @IBAction func backToQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
    
    func setupColors() {
        let c1 = UIColor.rgb(red: 196, green: 215, blue: 209)
        let c2 = UIColor.rgb(red: 227, green: 218, blue: 210)
        let c3 = UIColor.rgb(red: 253, green: 209, blue: 148)
        // let c2 = UIColor.rgb(red: 245, green: 209, blue: 195)
        // let c3 = UIColor.rgb(red: 240, green: 188, blue: 104)
        let c4 = UIColor.rgb(red: 206, green: 202, blue: 205)
        let c5 = UIColor.rgb(red: 170, green: 184, blue: 187)
        
        // let c1 = UIColor.rgb(red: 42, green: 73, blue: 101)
        // let c2 = UIColor.rgb(red: 154, green: 85, blue: 56)
        // let c3 = UIColor.rgb(red: 229, green: 153, blue: 133)
        // let c4 = UIColor.rgb(red: 224, green: 176, blue: 99)
        // let c5 = UIColor.rgb(red: 95, green: 149, blue: 99)
        
        colorArray.append(c1)
        colorArray.append(c2)
        colorArray.append(c3)
        colorArray.append(c4)
        colorArray.append(c5)
        
        colorCount = colorArray.count
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
            let request : NSFetchRequest<Quote> = Quote.fetchRequest()
            
            let predicate = NSPredicate(format: "quote CONTAINS[cd] %@", searchBar.text!)
            
            request.sortDescriptors = [NSSortDescriptor(key: "quote", ascending: true)]
            
            loadQuotes(with: request, predicate: predicate)
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
