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
    func handleDismissal(endEditMode: Bool)
}

class MoveCollectionViewController: UIViewController {
    
    // MARK: Variables
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let selectionHaptic = UISelectionFeedbackGenerator()
    
    var delegate: MoveCollectionViewControllerDelegate?
    
    var collectionArray = [Collection]()
    var selectedCollection = [Collection?]()
    
    var quotes = [Quote]()
    
    var edited = false
    
    // MARK: - IBOutlet
    @IBOutlet weak var collectionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionTableView.delegate = self
        collectionTableView.dataSource = self
        
        collectionTableView.allowsMultipleSelection = true
        
        loadCollections()
        
        // NOTE: if select multiple, no selectedCollection
        if quotes.count == 1 {
            selectedCollection = quotes.first!.collections?.allObjects as! [Collection]
        }
    }
    
    // MARK: - IBAction
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        print("done bar button clicked")
        
        if edited {
            var selectedArray = [Collection]()
            if let indexPaths = collectionTableView.indexPathsForSelectedRows {
                for i in indexPaths {
                    selectedArray.append(collectionArray[i.row])
                }
            }
            
            for quote in quotes {
                for c in quote.collections! {
                    quote.removeFromCollections(c as! Collection)
                }
                
                if selectedArray.count > 0 {
                    for c in selectedArray {
                        c.updatedOn = Date()
                        quote.addToCollections(c)
                    }
                }
            }
            
            saveContext()
        }
        dismissView(endEditMode: true)
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        print("cancel bar button clicked")
        dismissView(endEditMode: false)
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
        
        collectionTableView.reloadData()
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func dismissView(endEditMode: Bool) {
        dismiss(animated: true, completion: nil)
        
        self.delegate?.handleDismissal(endEditMode: endEditMode)
    }
    
    // MARK: - Unwind Segue
    @IBAction func backToMoveCollectionView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
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
extension MoveCollectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        
        cell.selectionStyle = .none
        
        let collection = collectionArray[indexPath.row]
        
        cell.collectionLabel?.text = collection.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let collection = collectionArray[indexPath.row]
        
        if selectedCollection.contains(collection) {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        edited = true
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        selectedCollection.append(collectionArray[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        edited = true
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        
        guard let index = selectedCollection.firstIndex(of: collectionArray[indexPath.row]) else { return }
        selectedCollection.remove(at: index)
    }
}
