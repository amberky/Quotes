//
//  AddQuoteViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class AddQuoteViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let selected = UIImage.init(named: "star-yellow")
    let unselected = UIImage.init(named: "star-gray-unfilled")
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var collectionLabel: UILabel!

    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
    @IBOutlet weak var collectionButton: UIButton!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var selectedCollection = [Collection?]() {
        didSet {
            setSelectedCollection()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        quoteTextField.becomeFirstResponder()
        quoteTextField.delegate = self
        authorTextField.delegate = self

        quoteTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        setupGesture()
    }
    
    func setSelectedCollection() {
        if selectedCollection.count > 0 {
            let concatCollection = selectedCollection.map { (m) -> String in
                m!.name ?? ""
            }.joined(separator: ", ")
            
            collectionButton.setTitle(concatCollection, for: .normal)
        } else {
            collectionButton.setTitle("None", for: .normal)
        }
    }
    
    func setupGesture() {
        let quoteLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(quoteLabelTapped))
        quoteLabel.addGestureRecognizer(quoteLabelTapGesture)
        
        let authorLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLabel.addGestureRecognizer(authorLabelTapGesture)
        
        let collectionLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionLabelTapped))
        collectionLabel.addGestureRecognizer(collectionLabelTapGesture)
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
    
    @objc func collectionLabelTapped() {
        print("collection label tapped")
        performSegue(withIdentifier: "goToSelectCollectionView", sender: self)
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
        doneButton.isEnabled = quoteTextField.text?.trimmingCharacters(in: .whitespaces) != "" ? true : false
    }
    
    //MARK: - unwind Segue: done Clicked, cancel Clicked
    @IBAction func backToAddQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        checkAndResignFirstResponder()
        
        switch identifier {
        case "doneClicked":
            let newQuote = Quote(context: self.context)
            newQuote.quote = quoteTextField.text!.trimmingCharacters(in: .whitespaces)
            newQuote.author = (authorTextField?.text ?? "").trimmingCharacters(in: .whitespaces)
            newQuote.isPin = false
            
            if selectedCollection.count > 0 {
                for c in selectedCollection {
                    newQuote.addToCollections(c!)
                }
            }
            
            newQuote.addedOn = Date()
            
            context.insert(newQuote)
            
            saveContext()
            
            print("Done bar button clicked")
            
            let destination = segue.destination as! QuoteViewController
            destination.loadQuotes()
            
        case "cancelClicked":
            print("Cancel bar button clicked")
            
        case "goToSelectCollectionView":
            print("Let's go to select a collection")
            
            let destination = segue.destination as! SelectCollectionViewController
            destination.selectedCollection = selectedCollection
            
        default:
            print("unknown segue identifier")
        }
    }
    
    func checkAndResignFirstResponder() {
        if quoteTextField.isFirstResponder {
            quoteTextField.resignFirstResponder()
        } else if authorTextField.isFirstResponder {
                authorTextField.resignFirstResponder()
        }
    }
}

extension AddQuoteViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == quoteTextField {
            authorTextField.becomeFirstResponder()
        } else {
            authorTextField.resignFirstResponder()
        }
        return false
    }
}
