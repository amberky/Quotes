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
    @IBOutlet weak var favouriteLabel: UILabel!
    
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
    @IBOutlet weak var collectionButton: UIButton!
    
    @IBOutlet weak var favouriteContainer: UIView!
    
    @IBOutlet weak var favouriteIcon: UIImageView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var selectedCollection : Collection? {
        didSet {
            setSelectedCollection()
        }
    }
    
    var isFavourite: Bool = false
    
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
        if selectedCollection != nil {
            collectionButton.setTitle(selectedCollection?.name ?? "none" , for: .normal)
        }
    }
    
    func setupGesture() {
        let quoteLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(quoteLabelTapped))
        quoteLabel.addGestureRecognizer(quoteLabelTapGesture)
        
        let authorLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLabel.addGestureRecognizer(authorLabelTapGesture)
        
        let collectionLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionLabelTapped))
        collectionLabel.addGestureRecognizer(collectionLabelTapGesture)
        
        let favouriteLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(favouriteTapped))
        favouriteLabel.addGestureRecognizer(favouriteLabelTapGesture)
        
        let favouriteContainerTapGesture = UITapGestureRecognizer(target: self, action: #selector(favouriteTapped))
        favouriteContainer.addGestureRecognizer(favouriteContainerTapGesture)
        
        let favouriteIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(favouriteTapped))
        favouriteIcon.addGestureRecognizer(favouriteIconTapGesture)
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
    
    @objc func favouriteTapped() {
        print("favourite tapped")
        
        if isFavourite == false {
            favouriteIcon.image = selected
            isFavourite = true
        } else {
            favouriteIcon.image = unselected
            isFavourite = false
        }
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
            newQuote.isFavourite = isFavourite
            newQuote.collection = selectedCollection
            newQuote.addedOn = Date()
            
            context.insert(newQuote)
            
            saveContext()
            
            print("Done bar button clicked")
            
            let destination = segue.destination as! QuoteViewController
            destination.loadQuotes()
            
        case "cancelClicked":
            print("Cancel bar button clicked")
            
        case "goToCollectionView":
            print("Let's go to select a collection")
            
            let destination = segue.destination as! SelectCollectionViewController
            destination.selectedCollection = selectedCollection?.name ?? ""
            
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
