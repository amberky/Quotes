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
    
    var quotesArray = [Quote]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var quoteTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // quoteTableView.register(UINib(nibName: "QuoteCell", bundle: nil) , forCellReuseIdentifier: "customQuoteCell")
        // quoteTableView.register(UINib(nibName: "MessageCell", bundle: nil) , forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        
        mockData()
        
        loadQuotes()
    }
    
    func loadQuotes(with request: NSFetchRequest<Quote> = Quote.fetchRequest(), predicate: NSPredicate? = nil) {
        //let request : NSFetchRequest<Quote> = Quote.fetchRequest()
        
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
    
    func mockData() {
        deleteData()
        
        let newQuote = Quote(context: self.context)
        newQuote.quote = "Focusing is about saying no"
        newQuote.author = "Steve Jobs"
        newQuote.year = 2019
        
        self.quotesArray.append(newQuote)
        
        let newQuote1 = Quote(context: self.context)
        newQuote1.quote = "Because the people who are crazy enough to think they can change the world are the ones who do"
        newQuote1.author = "Steve Jobs"
        newQuote1.year = 2019
        
        self.quotesArray.append(newQuote1)
        
        saveContext()
    }
    
    func deleteData() {
        let request: NSFetchRequest<Quote> = Quote.fetchRequest()
        
        do {
            let dataToBeDeleted = try context.fetch(request)
            
            for i in dataToBeDeleted
            {
                context.delete(i)
            }
            
            try context.save()
            
        } catch {
            
        }
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
        quoteTableView.rowHeight = UITableView.automaticDimension
        quoteTableView.estimatedRowHeight = 500.0
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteTableViewCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        let quote = quotesArray[indexPath.row]
        
        cell.quoteLabel.text = quote.quote
        cell.authorLabel.text = "\(quote.author ?? "") \(quote.year)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotesArray.count
    }
    
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue) {}
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

