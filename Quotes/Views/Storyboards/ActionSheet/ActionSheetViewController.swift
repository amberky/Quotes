//
//  ActionSheetViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

protocol ActionSheetViewControllerDelegate {
    func handleDismissal()
    
    func handleEditQuote(cell: QuoteTableViewCell)
    
    func handleMoveCollection(cell: QuoteTableViewCell)
}

class ActionSheetViewController: UIViewController {
    
    var delegate: ActionSheetViewControllerDelegate?

    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    lazy var editQuoteService = EditQuoteService()
    
    var cell = QuoteTableViewCell()
    
    var collections = [Collection]()
    
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hihi")
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        bgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped() {
        print("tapped")
        dismissActionSheet()
    }
    
    @IBAction func copyClicked(_ sender: Any) {
        print("copy")
        selectionHaptic.selectionChanged()
        
        guard let quote = cell.quoteLabel.text
            else { return }
        
        let copy = UIPasteboard.general
        copy.string = quote
        
        dismissActionSheet()
    }
    
    @IBAction func editClicked(_ sender: Any) {
        print("edit")
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
        delegate?.handleEditQuote(cell: cell)
    }
    
    @IBAction func moveClicked(_ sender: Any) {
        print("move")
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
        delegate?.handleMoveCollection(cell: cell)
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        print("share")
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        print("cancel")
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
    }
    
    func dismissActionSheet() {
        dismiss(animated: true, completion: nil)
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
