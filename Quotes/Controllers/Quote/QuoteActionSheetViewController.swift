//
//  QuoteActionSheetViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focusios. All rights reserved.
//

import UIKit
import CoreData

protocol QuoteActionSheetViewControllerDelegate {
    func handleDismissal()
    
    func handleEditQuote(cell: QuoteTableViewCell, objectId: NSManagedObjectID)
    
    func handleMoveCollection(quotes: [Quote])
    
    func handleRemoveFromCollection(reload: Bool)
    
    func handleShare(text: String)
}

class QuoteActionSheetViewController: UIViewController {
    
    // MARK: Variables
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    var quotes = [Quote]()
    
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
        
        let copy = UIPasteboard.general
        copy.string = concatText()
    
        dismissActionSheet()
    }
    
    @IBAction func editClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
    }
    
    @IBAction func moveClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
        
        delegate?.handleMoveCollection(quotes: quotes)
    }
    
    
    @IBAction func removeFromCollectionClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        if collection != nil {
            for quote in quotes {
                collection?.setValue(Date(), forKey: "updatedOn")
                quote.removeFromCollections(collection!)
                
                saveContext()
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
        delegate?.handleShare(text: concatText())
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
    
    func concatText() -> String {
        guard quotes.count > 0 else { return "" }
        
        var str = ""
        
        for i in quotes {
            if i.quote != nil {
                var text = i.quote
                if i.author != "" {
                    text = "\(text ?? "")\n- \(i.author ?? "")"
                }
                
                str = "\(str)\n\n\(text ?? "")"
            }
        }
        
        return str
    }
}
