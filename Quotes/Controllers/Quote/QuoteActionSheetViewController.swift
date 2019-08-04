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
    
    func handleEditQuote(cell: QuoteTableViewCell)
    
    func handleMoveCollection(cell: QuoteTableViewCell)
    
    func handleShare(cell: QuoteTableViewCell)
}

class QuoteActionSheetViewController: UIViewController {
    
    var delegate: QuoteActionSheetViewControllerDelegate?

    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    var cell = QuoteTableViewCell()
    
    var collections = [Collection]()
    
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        bgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped() {
        dismissActionSheet()
    }
    
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
        delegate?.handleEditQuote(cell: cell)
    }
    
    @IBAction func moveClicked(_ sender: Any) {
        selectionHaptic.selectionChanged()
        
        dismissActionSheet()
        delegate?.handleMoveCollection(cell: cell)
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
