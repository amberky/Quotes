//
//  QuoteActionSheetViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

protocol QuoteActionSheetViewControllerDelegate {
    func handleDismissal()
    
    func handleEditQuote(cell: QuoteTableViewCell, objectId: NSManagedObjectID)
    
    func handleMoveCollection(cell: QuoteTableViewCell)
    
    func handleRemoveFromCollection(reload: Bool)
    
    func handleShare(cell: QuoteTableViewCell)
}

class QuoteActionSheetViewController: UIViewController {
    
    // MARK: Variables
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    var cell = QuoteTableViewCell()
    var objectId: NSManagedObjectID? {
        didSet {
            print("didSet objectId")
        }
    }
    
    var collection: Collection? {
        didSet {
            print("didSet collection")
        }
    }
    
    var delegate: QuoteActionSheetViewControllerDelegate?

    // MARK: - IBOutlet
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var removeFromCollectionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        bgView.addGestureRecognizer(tapGesture)
        
        if collection == nil {
            removeFromCollectionView.isHidden = true
        } else {
            removeFromCollectionView.isHidden = false
        }
    }
    
    // MARK: - IBAction
    @IBAction func copyClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        guard cell.quoteLabel.text != nil
            else { return }
        
        var text = cell.quoteLabel.text
        if cell.authorLabel.text != "" {
            text = "\(text ?? "") \n- \(cell.authorLabel.text ?? "")"
        }
        
        let copy = UIPasteboard.general
        copy.string = text
        
        dismissActionSheet()
    }
    
    @IBAction func editClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
        delegate?.handleEditQuote(cell: cell, objectId: objectId!)
    }
    
    @IBAction func moveClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
        delegate?.handleMoveCollection(cell: cell)
    }
    
    
    @IBAction func removeFromCollectionClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        if collection != nil {
            let request: NSFetchRequest<Quote> = Quote.fetchRequest()
            request.predicate = NSPredicate(format: "quote == %@", cell.quoteLabel.text ?? "")
            
            do {
                if let quoteContext = try self.context.fetch(request) as [NSManagedObject]?, quoteContext.first != nil {
                    let quote = quoteContext.first as! Quote
                    
                    collection?.setValue(Date(), forKey: "updatedOn")
                    quote.removeFromCollections(collection!)
                    
                    saveContext()
                }
            } catch {
                print("Error in removing & adding collections to quote \(error)")
            }
            
            delegate?.handleRemoveFromCollection(reload: true)
        } else {
            delegate?.handleRemoveFromCollection(reload: false)
        }
        
        dismissActionSheet()
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
        delegate?.handleShare(cell: cell)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
    }
    
    // MARK: - Objc Functions
    @objc func tapped() {
        dismissActionSheet()
    }
    
    // MARK: - Functions
    func dismissActionSheet() {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.handleDismissal()
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
