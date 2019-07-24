//
//  AddQuoteViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class AddQuoteViewController: UIViewController, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var collectionButton: UIButton!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var selectedCollection : Collection? {
        didSet {
            print("didSet")
            setSelectedCollection()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        quoteTextField.delegate = self

        quoteTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        let quoteLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(quoteLabelTapped))
        quoteLabel.addGestureRecognizer(quoteLabelTapGesture)
        
        
        let authorLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLabel.addGestureRecognizer(authorLabelTapGesture)
        
    }
    
    func setSelectedCollection() {
        print("selectedCollection: \(selectedCollection?.name ?? "nil")")
        if selectedCollection != nil {
            collectionButton.setTitle(selectedCollection?.name ?? "none" , for: .normal)
        }
    }
    
    @objc func quoteLabelTapped() {
        print("quote label tapped")
        DispatchQueue.main.async {
            self.quoteTextField.becomeFirstResponder()
        }
    }
    
    @objc func authorLabelTapped() {
        print("author label tapped")
        self.authorTextField.becomeFirstResponder()
    }
    
    func saveContext() {
        do {
            try context.save()
            print("Saved successfully")
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = quoteTextField.text != "" ? true : false
    }
    
//    //MARK: - unwind Segue
    @IBAction func backToAddQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "doneClicked":
            let newQuote = Quote(context: self.context)
            newQuote.quote = quoteTextField.text!
            newQuote.author = authorTextField?.text ?? ""
            newQuote.collection = selectedCollection
            newQuote.addedOn = Date()
            
            context.insert(newQuote)
            
            saveContext()
            
            print("Done bar button clicked")
            
            let destination = segue.destination as! QuoteViewController
            destination.loadQuotes()
            
        case "cancelClicked":
            print("Cancel bar button clicked")
            
        case "goToCollection":
            print("Let's go to select a collection")
            
        default:
            print("unexpected segue identifier")
        }
    }
}
