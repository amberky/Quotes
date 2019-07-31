//
//  MoveCollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

protocol MoveCollectionViewControllerDelegate {
    
}

class MoveCollectionViewController: UIViewController {
    
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let selectionHaptic = UISelectionFeedbackGenerator()
    
    var collectionArray = [Collection]()
    var selectedCollection = [Collection?]()
    
    var delegate: MoveCollectionViewControllerDelegate?
    
    var cell = QuoteTableViewCell()
        //MARK: - IBOutlet
    @IBOutlet weak var collectionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionTableView.delegate = self
        collectionTableView.dataSource = self
        
        collectionTableView.allowsMultipleSelection = true
        
        loadCollections()
        
        selectedCollection = cell.quote?.collections?.allObjects as! [Collection]
    }
    
    func loadCollections() {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        
        do {
            collectionArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        collectionTableView.reloadData()
    }
    
    //MARK: - IBAction
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        print("done bar button clicked")
        
        var selectedArray = [Collection]()
        if let indexPaths = collectionTableView.indexPathsForSelectedRows {
            for i in indexPaths {
                selectedArray.append(collectionArray[i.row])
            }
        }
        
        let request: NSFetchRequest<Quote> = Quote.fetchRequest()
        request.predicate = NSPredicate(format: "quote == %@", cell.quoteLabel.text ?? "")
        
        do {
            if let quoteContext = try self.context.fetch(request) as [NSManagedObject]?, quoteContext.first != nil {
                let quote = quoteContext.first as! Quote
                
                for c in quote.collections! {
                    quote.removeFromCollections(c as! Collection)
                }
                
                if selectedArray.count > 0 {
                    for c in selectedArray {
                        quote.addToCollections(c)
                    }
                }
                
                saveContext()
            }
        } catch {
            print("Error in removing & adding collections to quote \(error)")
        }
        
        dismissView()
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        print("cancel bar button clicked")
    }
    
    //MARK: - unwind Segue
    @IBAction func backToMoveCollectionView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "goToAddCollectionFromMoveView":
            // perform Add New Collection
            // nothing to pass to Collection view
            print("Let's go to add new collection for move category")
        default:
            print("unknown segue identifier")
        }
    }
}

extension MoveCollectionViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath)
        
        cell.selectionStyle = .none
        
        let collection = collectionArray[indexPath.row]
        
        cell.textLabel?.text = collection.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let collection = collectionArray[indexPath.row]
        
        if selectedCollection.contains(collection) {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
