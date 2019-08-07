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
    
    // MARK: Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var maxLength: Int = 500
    
    var selectedCollection = [Collection?]() {
        didSet {
            setSelectedCollection()
        }
    }
    
    var activeField: UITextField?
    
    // MARK: - IBOutlet
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var collectionLabel: UILabel!

    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
    @IBOutlet weak var collectionButton: UIButton!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        quoteTextField.becomeFirstResponder()
        quoteTextField.delegate = self
        authorTextField.delegate = self

        quoteTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        setupGesture()
        setupNotificationCenter()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: - Objc Functions
    @objc func quoteLabelTapped() {
        DispatchQueue.main.async {
            self.quoteTextField.becomeFirstResponder()
        }
    }
    
    @objc func authorLabelTapped() {
        self.authorTextField.becomeFirstResponder()
    }
    
    @objc func collectionLabelTapped() {
        performSegue(withIdentifier: "goToSelectCollectionView", sender: self)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = quoteTextField.text?.trimmingCharacters(in: .whitespaces) != "" ? true : false
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        
        guard let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let estimatedHeight = kbSize.height + 50
        
        if notification.name != UIResponder.keyboardWillHideNotification {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: estimatedHeight, right: 0)
            
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
//            // If active text field is hidden by keyboard, scroll it so it's visible
//            // Your app might not need or want this behavior.
//            var aRect = self.view.frame;
//            aRect.size.height = aRect.size.height - kbSize.height;
//            
//            if aRect.contains((activeField?.frame.origin ?? CGPoint(x: 0, y: 0))) {
//                scrollView.scrollRectToVisible(activeField!.frame, animated: true)
//            }
            
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
    
    // MARK: - Functions
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
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func saveContext() {
        do {
            try context.save()
            print("Saved successfully")
        } catch {
            print("Error saving data from context \(error)")
        }
    }
    
    func checkQuoteExists(quote: String) -> Bool {
        let predicate = NSPredicate(format: "quote == %@", quote)
        let request : NSFetchRequest<Quote> = Quote.fetchRequest()
        request.predicate = predicate
        
        do {
            let result = try self.context.fetch(request) as [NSManagedObject]?
            
            if (result?.count ?? 0) > 0 {
                
                showExistAlert()
                
                return true
            } else {
                return false
            }
        } catch {
            print("Error in checking quote exists \(error)")
        }
        
        return false
    }
    
    func showExistAlert() {
        let alert = UIAlertController(title: "Quote is Already Added", message: "This Quote has already been added.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.quoteTextField.becomeFirstResponder()
        }
        
        alert.addAction(action)
        alert.view.tintColor = UIColor.mainBlue()
        
        present(alert, animated: true, completion: nil)
    }
    
    func checkAndResignFirstResponder() {
        if quoteTextField.isFirstResponder {
            quoteTextField.resignFirstResponder()
        } else if authorTextField.isFirstResponder {
            authorTextField.resignFirstResponder()
        }
    }
    
    // MARK: - Unwind Segue
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
                    c?.updatedOn = Date()
                    newQuote.addToCollections(c!)
                }
            }
            
            newQuote.addedOn = Date()
            newQuote.updatedOn = Date()
            
            context.insert(newQuote)
            
            saveContext()
            
            print("Done bar button clicked")
            
            let destination = segue.destination as! QuoteViewController
            destination.loadQuotes()
            
        case "cancelClicked":
            print("Cancel bar button clicked")
            
        case "goToAddSelectCollectionView":
            print("Let's go to select a collection")
            
            let destination = segue.destination as! SelectCollectionViewController
            destination.selectedCollection = selectedCollection
            
        default:
            print("unknown segue identifier")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("shouldPerformSegue")
        
        checkAndResignFirstResponder()
        
        switch identifier {
        case "doneClicked":
            let quote = quoteTextField.text!.trimmingCharacters(in: .whitespaces)
            
            if checkQuoteExists(quote: quote) == true {
                return false
            } else {
                return true
            }
        default:
            return true
        }
    }
}

// MARK: - UITextFieldDelegate
extension AddQuoteViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        
        let aRect = self.view.frame;
        
        if aRect.contains((activeField?.frame.origin ?? CGPoint(x: 0, y: 0))) {
            self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == quoteTextField {
            authorTextField.becomeFirstResponder()
        } else {
            authorTextField.resignFirstResponder()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text, let rangeOfTextToReplace = Range(range, in: textFieldText) else { return false }
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        if count > maxLength {
            textField.Shake()
        }
        
        return count <= maxLength
    }
}
