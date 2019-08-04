//
//  CollectionActionSheetViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

protocol CollectionActionSheetViewControllerDelegate {
    func handleDismissal()
    
    func handleDismissalBackToCollectionView()
}

class CollectionActionSheetViewController: UIViewController {
    
    var delegate: CollectionActionSheetViewControllerDelegate?
    
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    var collection: CollectionModel?
    
    var collections = [Collection]()
    
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        bgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped() {
        dismissActionSheet(with: "")
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", collection?.name ?? "")
        
        do {
            if let collection = try self.context.fetch(request) as [NSManagedObject]? {
                if collection.count > 0 {
                    self.context.delete(collection[0])
                    self.saveContext()
                }
            }
        } catch {
            print("Error deleting data \(error)")
        }
        
        dismissActionSheet(with: "BackToCollectionView")
    }
    
    
    @IBAction func cancelClicked(sender: AnyObject) {
        selectionHaptic.selectionChanged()
        
        dismissActionSheet(with: "")
    }
    
    func dismissActionSheet(with destination: String) {
        switch destination {
        case "BackToCollectionView":
            UIView.animate(withDuration: 0.5) {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
                self.delegate?.handleDismissalBackToCollectionView()
            }
        default:
            UIView.animate(withDuration: 0.5) {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.handleDismissal()
            }
        }
        
        delegate?.handleDismissal()
    }
    
    func saveContext() {
        do {
            try context.save()
            print("Saved successfully")
        } catch {
            print("Error saving data from context \(error)")
        }
    }
}

