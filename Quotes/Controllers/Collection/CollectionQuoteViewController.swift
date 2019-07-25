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
    
    //MARK: - IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var quoteTableView: UITableView!
    
    var selectedCollection: CollectionModel? {
        didSet {
            print("didSet")
            //            print(self.selectedCollection ?? nil)
            setTitle()
            loadQuotes()
        }
    }
    
    var quoteArray = [Quote]()
    
    var colorArray = ColorTheme.init().colorArray
    var colorCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quoteTableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil) , forCellReuseIdentifier: "QuoteCell")
        
        quoteTableView.delegate = self
        quoteTableView.dataSource = self
        
        colorCount = colorArray.count
    }
    
    func setTitle() {
        self.title = selectedCollection?.name
    }
    
    func loadQuotes(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Quote> = Quote.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "addedOn", ascending: false)]
        
        if selectedCollection?.isAll == false {
            if predicate != nil {
                let collectionPredicate = NSPredicate(format: "collection.name == %@", selectedCollection!.name)
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [collectionPredicate, predicate!])
            } else {
                request.predicate = NSPredicate(format: "collection.name == %@", selectedCollection!.name)
            }
        } else if predicate != nil {
            request.predicate = predicate
        }
        
        do {
            quoteArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
}

extension CollectionQuoteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        cell.quoteBackground.backgroundColor = .white
        cell.quoteBackground.layer.shadowOpacity = 0.2
        cell.quoteBackground.layer.shadowRadius = 2
        cell.quoteBackground.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.quoteBackground.layer.shadowColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    //MARK: - unwindSegue
    @IBAction func backToCategoryQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
}

//MARK: - Search Bar methods
extension CollectionQuoteViewController: UISearchBarDelegate {
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
