//
//  EditQuoteViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

protocol EditQuoteViewControllerDelegate {
    func reloadQuote()
}

class EditQuoteViewController: UIViewController {
    
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate: EditQuoteViewControllerDelegate?

    //MARK: - IBOutlet
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
//    @IBOutlet weak var collectionLabel: UILabel!
    
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
//    @IBOutlet weak var collectionButton: UIButton!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var cell = QuoteTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        quoteTextField.becomeFirstResponder()
        quoteTextField.delegate = self
        authorTextField.delegate = self
        quoteTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        setupView()
        setupGesture()
    }
    
    func setupView() {
        quoteTextField.text = cell.quoteLabel.text
        authorTextField.text = cell.authorLabel.text
        
//        guard let collections = cell.quote?.collections?.allObjects as? [Collection] else { return }
//
//        if (collections.count) > 0 {
//            let concatCollection = collections.map { (m) -> String in
//                m.name ?? ""
//                }.joined(separator: ", ")
//
//            collectionButton.setTitle(concatCollection, for: .normal)
//        } else {
//            collectionButton.setTitle("None", for: .normal)
//        }
    }
    
    func setupGesture() {
        let quoteLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(quoteLabelTapped))
        quoteLabel.addGestureRecognizer(quoteLabelTapGesture)
        
        let authorLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLabel.addGestureRecognizer(authorLabelTapGesture)
        
//        let collectionLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionLabelTapped))
//        collectionLabel.addGestureRecognizer(collectionLabelTapGesture)
    }
    
    @objc func quoteLabelTapped() {
        DispatchQueue.main.async {
            self.quoteTextField.becomeFirstResponder()
        }
    }
    
    @objc func authorLabelTapped() {
        self.authorTextField.becomeFirstResponder()
    }
    
    @objc func collectionLabelTapped() {
        performSegue(withIdentifier: "goToEditSelectCollectionView", sender: self)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = quoteTextField.text?.trimmingCharacters(in: .whitespaces) != "" ? true : false
    }
    
    func saveContext() {
        do {
            try context.save()
            print("Saved successfully")
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        print("Done bar button clicked")
        
        checkAndResignFirstResponder()
        
        let request: NSFetchRequest<Quote> = Quote.fetchRequest()
        request.predicate = NSPredicate(format: "quote == %@", cell.quoteLabel.text ?? "")
        
        do {
            if let quoteContext = try self.context.fetch(request) as [NSManagedObject]?, quoteContext.first != nil {
                let quote = quoteContext.first as! Quote
                
                quote.setValue(quoteTextField.text!.trimmingCharacters(in: .whitespaces), forKey: "quote")
                quote.setValue((authorTextField?.text ?? "").trimmingCharacters(in: .whitespaces), forKey: "author")
                quote.setValue(Date(), forKey: "updatedOn")
                
                saveContext()
            }
        } catch {
            print("Error in removing & adding collections to quote \(error)")
        }
        
        dimissView(reload: true)
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        print("Cancel bar button clicked")
        checkAndResignFirstResponder()
        
        dimissView(reload: false)
    }
    
    func dimissView(reload: Bool) {
        dismiss(animated: true, completion: nil)
        
        if reload {
            delegate?.reloadQuote()
        }
    }
    
    @IBAction func backToEditQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
    func checkAndResignFirstResponder() {
        if quoteTextField.isFirstResponder {
            quoteTextField.resignFirstResponder()
        } else if authorTextField.isFirstResponder {
            authorTextField.resignFirstResponder()
        }
    }
}

extension EditQuoteViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == quoteTextField {
            authorTextField.becomeFirstResponder()
        } else {
            authorTextField.resignFirstResponder()
        }
        return false
    }
}
