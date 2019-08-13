//
//  CollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 24/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import CoreData

class CollectionViewController: UICollectionViewController {
    
    // MARK: Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var collectionArray = [CollectionModel]()
    var selectedCollection: CollectionModel?
    
    let iconMode = "-light" // -dark or -light
    let beigeColor = UIColor.mainBeige()
    
    var defaultIcon = "bookmark"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.scrollsToTop = true
        loadCollections()
    }
    
    // MARK: Functions
    func loadCollections() {
        collectionArray = [CollectionModel]()
        
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        let sort = [NSSortDescriptor(key: "updatedOn", ascending: false)]
        
        request.sortDescriptors = sort
        
        let quoteRequest: NSFetchRequest<Quote> = Quote.fetchRequest()
        var totalCount = 0
        
        do {
            totalCount = try context.fetch(quoteRequest).count
            
            let collectionContext = try context.fetch(request)
            
            collectionArray.insert(CollectionModel.init(name: "All",
                                                        icon: defaultIcon,
                                                        count: totalCount,
                                                        objectID: nil,
                                                        isAll: true), at: 0)
            for i in collectionContext {
                collectionArray.append(CollectionModel.init(name: i.name ?? "",
                                                            icon: i.icon ?? "",
                                                            count: i.quotes?.count ?? 0,
                                                            objectID: i.objectID))
            }
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        collectionView.reloadData()
    }
    
    // MARK: - Unwind Segue
    @IBAction func backToCollectionView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "goToCollectionQuoteView":
            print("Let's go to collection-quote view")
            
            if let indexPath = collectionView.indexPathsForSelectedItems {
                if let firstItem = indexPath.first {
                    let destinationVC = segue.destination as! CollectionQuoteViewController
                    destinationVC.selectedCollection = collectionArray[firstItem.row]
                }
            }
        default:
            print("unknown segue identifier")
        }
    }
}

// MARK: - UICollectionView
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20 - 40) / 2
        let height = width + 20 + 20

        print(collectionView.frame.width)
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collection = collectionArray[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCollectionViewCell", for: indexPath) as! CollectionCollectionViewCell
        
        let imagePath = "\(collection.icon)\(iconMode)"
        
        cell.collectionImage.image = UIImage.init(named: imagePath)
        
        cell.collectionImage.backgroundColor = UIColor.mainUnSelected()
        
        cell.collectionLabel.text = collection.name
        cell.quoteCountLabel.text = "\(collection.count) Quotes"
        
        return cell
    }
}
