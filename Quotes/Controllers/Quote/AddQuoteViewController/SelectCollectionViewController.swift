//
//  SelectCollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import CoreData

class SelectCollectionViewController: UITableViewController {
    
    // MARK: Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let selection = UISelectionFeedbackGenerator()
    
    var collectionArray = [Collection]()
    var selectedCollection = [Collection?]()

    lazy var checked = 0
    lazy var interminate = 1
    lazy var unchecked = 2
    
    // MARK: - IBOutlet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCollections()
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
    
    // MARK: - Unwind Segue
    @IBAction func backToSelectCollectionView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "doneClicked":
            print("Done bar button clicked")
            
            let destinationVC = segue.destination as! AddQuoteViewController
            destinationVC.selectedCollection = selectedCollection
            
        case "cancelClicked":
            print("Cancel bar button clicked")
        
        case "goToAddCollectionView":
            // perform Add New Collection
            // nothing to pass to Collection view
            print("Let's go to add new collection")
        default:
            print("unknown segue identifier")
        }
    }
}

// MARK: - UITableViewDelegate
extension SelectCollectionViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        
        let collection = collectionArray[indexPath.row]
        
        cell.collection = collection
        
        if selectedCollection.contains(collection) {
            cell.rowSelected = checked
        } else {
            cell.rowSelected = unchecked
        }
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("didSelectRowAt")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        
        let collection = collectionArray[indexPath.row]

        if selectedCollection.contains(collection) {
            cell.rowSelected = checked
            selectedCollection.remove(at: selectedCollection.firstIndex(of: collection)!)
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            cell.rowSelected = checked
            selectedCollection.append(collection)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}
