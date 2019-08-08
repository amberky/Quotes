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
    
    // MARK: Variables
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var maxLength: Int = 500
    
    var delegate: EditQuoteViewControllerDelegate?

    var cell = QuoteTableViewCell()
    var objectId : NSManagedObjectID?
    
    // MARK: - IBOutlet
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quoteTextField.delegate = self
        authorTextField.delegate = self
        quoteTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        setupView()
        setupGesture()
        setupNotificationCenter()
    }
    
    // MARK: - IBAction
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        print("Done bar button clicked")
        
        checkAndResignFirstResponder()
        
        let quote = quoteTextField.text!.trimmingCharacters(in: .whitespaces)
        
        if checkQuoteExists(quote: quote) == false {
            updateQuote(quote: quote)
            dimissView(reload: true)
        }
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        print("Cancel bar button clicked")
        checkAndResignFirstResponder()
        
        dimissView(reload: false)
    }
    
    @IBAction func backToEditQuoteView(_ unwindSegue: UIStoryboardSegue) {}
    
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
        performSegue(withIdentifier: "goToEditSelectCollectionView", sender: self)
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

        } else {
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
    
    // MARK: - Functions
    func setupView() {
        quoteTextField.text = cell.quoteLabel.text
        authorTextField.text = cell.authorLabel.text
    }
    
    func setupGesture() {
        let quoteLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(quoteLabelTapped))
        quoteLabel.addGestureRecognizer(quoteLabelTapGesture)
        
        let authorLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLabel.addGestureRecognizer(authorLabelTapGesture)
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
    
    func updateQuote(quote: String) {
        let request: NSFetchRequest<Quote> = Quote.fetchRequest()
        request.predicate = NSPredicate(format: "quote == %@", cell.quoteLabel.text ?? "")
        
        do {
            if let quoteContext = try self.context.fetch(request) as [NSManagedObject]?, quoteContext.first != nil {
                let updateQuote = quoteContext.first as! Quote
                
                updateQuote.setValue(quote, forKey: "quote")
                updateQuote.setValue((authorTextField?.text ?? "").trimmingCharacters(in: .whitespaces), forKey: "author")
                updateQuote.setValue(Date(), forKey: "updatedOn")
                
                saveContext()
            }
        } catch {
            print("Error in removing & adding collections to quote \(error)")
        }
    }
    
    func checkQuoteExists(quote: String) -> Bool {
        let predicate = NSPredicate(format: "quote == %@", quote)
        let request : NSFetchRequest<Quote> = Quote.fetchRequest()
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request) as [NSManagedObject]?
            
            if (result?.count ?? 0) > 0 && result?.first?.objectID != objectId {
                showExistsAlert()
                
                return true
            }
        } catch {
            print("Error in checking quote exists \(error)")
        }
        
        return false
    }
    
    func showExistsAlert() {
        let alert = UIAlertController(title: "Quote is Already Added",
                                      message: "This Quote has already been added.",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.quoteTextField.becomeFirstResponder()
        }
        
        alert.addAction(action)
        alert.view.tintColor = UIColor.mainBlue()
        
        present(alert, animated: true, completion: nil)
    }
    
    func dimissView(reload: Bool) {
        dismiss(animated: true, completion: nil)
        
        if reload {
            delegate?.reloadQuote()
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

// MARK: - UITextFieldDelegate
extension EditQuoteViewController : UITextFieldDelegate {
    
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
            print("MaxLength \(count)")
            textField.Shake()
        }
        
        return count <= maxLength
    }
}
