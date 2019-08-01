//
//  CollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 24/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class CollectionViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - IBOutlet
    @IBOutlet weak var collectionCollectionView: UICollectionView!
    
    //MARK: Variables
    var collectionArray = [CollectionModel]()
    var selectedCollection: CollectionModel?
    
    let iconMode = "-light" // -dark or -light
    let beigeColor = UIColor.mainBeige()
    
    var defaultIcon = "bookmark"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionCollectionView.delegate = self
        collectionCollectionView.dataSource = self
        
        collectionCollectionView.allowsMultipleSelection = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCollections()
    }
    
    func loadCollections() {
        collectionArray = [CollectionModel]()
        
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        let sort = [NSSortDescriptor(key: "addedOn", ascending: true)]
        
        request.sortDescriptors = sort
        
        let quoteRequest: NSFetchRequest<Quote> = Quote.fetchRequest()
        var totalCount = 0
        
        do {
            totalCount = try context.fetch(quoteRequest).count
            
            let collectionContext = try context.fetch(request)
            
            collectionArray.insert(CollectionModel.init(name: "All", icon: defaultIcon, count: totalCount, isAll: true), at: 0)
            for i in collectionContext {
                collectionArray.append(CollectionModel.init(name: i.name ?? "", icon: i.icon ?? "", count: i.quotes?.count ?? 0))
            }
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        collectionCollectionView.reloadData()
    }
    
    //MARK: - IBAction
    
    //MARK: - unwind Segue
    @IBAction func backToCollectionView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "goToCollectionQuoteView":
            print("Let's go to collection-quote view")
            
            if let indexPath = collectionCollectionView.indexPathsForSelectedItems {
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

extension CollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20 - 40) / 2
        let height = width + 20 + 20
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
