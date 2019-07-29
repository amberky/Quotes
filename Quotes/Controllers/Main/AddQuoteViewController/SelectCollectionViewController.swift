//
//  SelectCollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class SelectCollectionViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let selection = UISelectionFeedbackGenerator()
    
    var collectionArray = [Collection]()
    var selectedCollection = [Collection?]()
    
    //MARK: - IBOutlet
    @IBOutlet weak var collectionTableView: UITableView!
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionTableView.delegate = self
        collectionTableView.dataSource = self
        
        collectionTableView.allowsMultipleSelection = true
        
        loadCollections()
    }
    
    func loadCollections() {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        
        do {
            collectionArray = try context.fetch(request)
            
            //            collectionArray = collectionContext.map({ (m) -> CollectionModel in
            //                return CollectionModel.init(collectionName: m.name ?? "", collectionIcon: m.icon ?? "", showAll: false, selected: false)
            //            })
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        collectionTableView.reloadData()
    }
    
    //MARK: - unwind Segue
    @IBAction func backToSelectCollectionView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "doneClicked":
            print("Done bar button clicked")
            if let indexPath = collectionTableView.indexPathsForSelectedRows {
                let destinationVC = segue.destination as! AddQuoteViewController
                
                var selectedArray = [Collection]()
                
                for i in indexPath {
                    selectedArray.append(collectionArray[i.row])
                }
                
                destinationVC.selectedCollection = selectedArray
            }
            
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

extension SelectCollectionViewController: UITableViewDataSource, UITableViewDelegate {
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
