//
//  CollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class CollectionViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var collectionArray = [Collection]()
    
    //MARK: - IBOutlet
    @IBOutlet weak var collectionTableView: UITableView!
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionTableView.delegate = self
        collectionTableView.dataSource = self
        
        loadCategories()
    }
    
    func loadCategories() {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        
        do {
            collectionArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        collectionTableView.reloadData()
    }
    
    //MARK: - unwind Segue
    @IBAction func backToCollectionView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "cancelClicked":
            print("Cancel bar button clicked")
            
        case "collectionSelected":
            print("Collection Selected")
            let destinationVC = segue.destination as! AddQuoteViewController
            
            if let indexPath = collectionTableView.indexPathForSelectedRow {
                destinationVC.selectedCollection = collectionArray[indexPath.row]
            }
            
        case "goToAddCollectionView":
            print("Let's go to add new collection")
            
        default:
            print("unexpected segue identifier")
        }
    }
}

extension CollectionViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath)
        
        let collection = collectionArray[indexPath.row]
        
        cell.textLabel?.text = collection.name
        
        return cell
    }
}
