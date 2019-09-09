//
//  MoveCollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import CoreData

protocol MoveCollectionViewControllerDelegate {
    func handleDismissal(endEditMode: Bool, reload: Bool)
}

class MoveCollectionViewController: UITableViewController {
    
    // MARK: Variables
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let selectionHaptic = UISelectionFeedbackGenerator()
    
    var delegate: MoveCollectionViewControllerDelegate?
    
    var collectionArray = [Collection]()
    var selectedCollection = [Collection?]()
    var removedCollection = [Collection?]()
    
    var quotes = [Quote]()
    
    var edited = false
    
    lazy var checked = 0
    lazy var interminate = 1
    lazy var unchecked = 2
    
    var qCollections = [Collection?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        loadCollections()
        configureTableView()
    }
    
    func configureTableView() {
        for i in quotes {
            for j in (i.collections?.allObjects as! [Collection]) {
                qCollections.append(j)
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        print("done bar button clicked")
        
        if edited {
            for quote in quotes {
//                for c in quote.collections! {
//                    quote.removeFromCollections(c as! Collection)
//                }
                
                if removedCollection.count > 0 {
                    for c in removedCollection {
                        c!.updatedOn = Date()
                        
                        if quote.collections?.contains(c!) == true {
                            quote.removeFromCollections(c!)
                        }
                    }
                }
                
                if selectedCollection.count > 0 {
                    for c in selectedCollection {
                        c!.updatedOn = Date()
                        
                        if quote.collections?.contains(c!) == false {
                            quote.addToCollections(c!)
                        }
                    }
                }
            }
            
            saveContext()
        }
        dismissView(endEditMode: true, reload: true)
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        print("cancel bar button clicked")
        dismissView(endEditMode: false, reload: false)
    }
    
    // MARK: - Functions
    func loadCollections() {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        let sort = [NSSortDescriptor(key: "updatedOn", ascending: false)]
        
        request.sortDescriptors = sort
        
        do {
            collectionArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func dismissView(endEditMode: Bool, reload: Bool) {
        dismiss(animated: true, completion: nil)
        
        self.delegate?.handleDismissal(endEditMode: endEditMode, reload: reload)
    }
    
    // MARK: - Unwind Segue
    @IBAction func backToMoveCollectionView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        print("prepare")
        switch identifier {
        case "goToAddCollectionFromMoveView":
            // perform Add New Collection
            // nothing to pass to Collection view
            print("Let's go to add new collection for move collection")
        default:
            print("unknown segue identifier")
        }
    }
}

// MARK: - UITableViewDelegate
extension MoveCollectionViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        
        cell.selectionStyle = .none
        
        let collection = collectionArray[indexPath.row]
        
        cell.collectionLabel?.text = collection.name
        print("cellForRowAt")
        
        let collectionCount = qCollections.filter({ (m) -> Bool in m?.name == collection.name }).count
        
        if selectedCollection.contains(collection) {
            cell.rowSelected = checked
        } else if removedCollection.contains(collection) {
            cell.rowSelected = unchecked
        } else if collectionCount > 0 {
            if collectionCount == quotes.count {
                cell.rowSelected = checked
                selectedCollection.append(collection)
            } else {
                cell.rowSelected = interminate
            }
        } else {
            cell.rowSelected = unchecked
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        edited = true

        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        let collection = collectionArray[indexPath.row]
        
        if selectedCollection.contains(collection) {
            cell.rowSelected = unchecked
            tableView.deselectRow(at: indexPath, animated: false)
            
            guard let index = selectedCollection.firstIndex(of: collection) else { return }
            selectedCollection.remove(at: index)
            
            if qCollections.contains(collection) {
                removedCollection.append(collection)
            }
        } else {
            cell.rowSelected = checked
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
            selectedCollection.append(collection)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
