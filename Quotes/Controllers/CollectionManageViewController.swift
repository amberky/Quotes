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
    var collectionArray = [Collection]()
    
    let iconMode = "-light" // -dark or -light
    let beigeColor = UIColor.rgb(red: 230, green: 227, blue: 226)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionCollectionView.delegate = self
        collectionCollectionView.dataSource = self
        
        loadCollections()
    }
    
    func loadCollections() {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        
        do {
            collectionArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        collectionCollectionView.reloadData()
    }
    
    //MARK: - IBAction
    
    //MARK: - unwind Segue
    @IBAction func backToCollectionManageView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToCollectionQuoteView":
            print("Let's go to Collection Quote View")
        default:
            print("unknown segue identifier")
        }
    }
    
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 40) / 3
        let height = width + 20
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collection = collectionArray[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCollectionViewCell", for: indexPath) as! CollectionCollectionViewCell
        
        if collection.icon != nil {
            let imagePath = "\(collection.icon ?? "")\(iconMode)"
            cell.collectionImage.image = UIImage.init(named: imagePath)
        }
        
        cell.collectionImage.backgroundColor = beigeColor
        cell.collectionLabel.text = collection.name
        
        return cell
    }
}
