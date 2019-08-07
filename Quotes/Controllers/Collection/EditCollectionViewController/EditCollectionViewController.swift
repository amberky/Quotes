//
//  EditCollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class EditCollectionViewController: UIViewController {
    
    // MARK: - Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var collectionActionSheetService = CollectionActionSheetService()
    
    lazy var maxLength: Int = 500
    
    let iconMode = "-light" // -dark or -light
    lazy var iconArray = IconThemeModel.init(iconMode: iconMode, alpha: 1).iconArray
    
    lazy var unselectedColor = UIColor.mainUnSelected()
    lazy var selectedColor = UIColor.mainSelected()
    
    var selectedIndex = 0
    
    var selectedCollection: CollectionModel?
    
    var activeField: UITextField?
    
    // MARK: - IBOutlet
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionLabel: UILabel!
    
    @IBOutlet weak var collectionTextField: UITextField!
    
    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if selectedCollection != nil {
        doneButton.isEnabled = false
        
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        
        let nib = UINib.init(nibName: "SmallIconCollectionViewCell", bundle: nil)
        iconCollectionView.register(nib, forCellWithReuseIdentifier: "SmallIconCollectionViewCell")
        
        collectionTextField.delegate = self
        
        collectionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        bindValueToComponents()
        
        setupGesture()
        setupNotificationCenter()
    }
    
    // MARK: - IBAction
    @IBAction func deleteButtonClicked(_ sender: Any) {
        checkAndResignFirstResponder()
        
        let collectionActionSheetVC = collectionActionSheetService.show(collection: selectedCollection!)
        collectionActionSheetVC.delegate = self
        
        self.view.alpha = 0.6;
        self.present(collectionActionSheetVC, animated: true)
    }
    
    // MARK: - Objc Functions
    @objc func collectionLabelTapped() {
        print("collection label tapped")
        DispatchQueue.main.async {
            self.collectionTextField.becomeFirstResponder()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = collectionTextField.text != "" ? true : false
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        
        guard let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let estimatedHeight = kbSize.height + 20
        
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
    func bindValueToComponents() {
        if selectedCollection != nil {
            collectionTextField.text = selectedCollection?.name
            
            let index = iconArray.map({ (item) -> String in
                item.name
            }).firstIndex(of: selectedCollection?.icon ?? "")
            selectedIndex = index ?? 0
            
            doneButton.isEnabled = true
            
            iconCollectionView.reloadData()
        }
    }
    
    func setupGesture() {
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
    
    func checkCollectionExists(name: String) -> Bool {
        let predicate = NSPredicate(format: "name == %@", name)
        let request : NSFetchRequest<Collection> = Collection.fetchRequest()
        request.predicate = predicate
        
        do {
            let result = try self.context.fetch(request) as [NSManagedObject]?
            
            if (result?.count ?? 0) > 0 {
                if result?.first?.objectID != selectedCollection?.objectID {
                    return true
                }
            }
        } catch {
            print("Error in checking collection exists \(error)")
        }
        
        return false
    }
    
    func showExistAlert() {
        let alert = UIAlertController(title: "Collection Already Exists", message: "Please choose a different name.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.collectionTextField.becomeFirstResponder()
        }
        
        alert.addAction(action)
        alert.view.tintColor = UIColor.mainBlue()
        
        present(alert, animated: true, completion: nil)
    }
    
    func checkAndResignFirstResponder() {
        if collectionTextField.isFirstResponder {
            collectionTextField.resignFirstResponder()
        }
    }
    
    func backToCollectionView() {
        performSegue(withIdentifier: "backToCollectionView", sender: self)
    }
    
    // MARK: - Unwind Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        checkAndResignFirstResponder()
        
        switch identifier {
        case "doneClicked":
            print("Done bar button clicked")
            
            let collectionName = collectionTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
            let newIcon = iconArray[selectedIndex].name
            
            if collectionName != selectedCollection?.name || selectedCollection!.icon != newIcon {
                let updatedCollection = CollectionModel.init(name: collectionName, icon: iconArray[selectedIndex].name)
                
                let request: NSFetchRequest<Collection> = Collection.fetchRequest()
                request.predicate = NSPredicate(format: "name == %@", selectedCollection!.name)
                
                do {
                    if let collection = try context.fetch(request) as [NSManagedObject]? {
                        if collection.first != nil {
                            collection.first!.setValue(updatedCollection.name, forKey: "name")
                            collection.first!.setValue(updatedCollection.icon, forKey: "icon")
                            collection.first!.setValue(Date(), forKey: "updatedOn")
                            
                            saveContext()
                        }
                    }
                } catch {
                    print("Error fetching/ updating data \(error)")
                }
                
                let destination = segue.destination as! CollectionQuoteViewController
                destination.title = collectionTextField.text ?? ""
                destination.selectedCollection = updatedCollection
                destination.loadQuotes()
            }
            
        case "cancelClicked":
            print("Cancel bar button clicked")
        default:
            print("unknown segue identifier")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("shouldPerformSegue")
        
        checkAndResignFirstResponder()
        
        switch identifier {
        case "doneClicked":
            let collectionName = collectionTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
            
            if checkCollectionExists(name: collectionName) == true {
                print("checkCollectionExists false")
                
                showExistAlert()
                
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
extension EditCollectionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        
        let aRect = self.view.frame;
        
        if aRect.contains((activeField?.frame.origin ?? CGPoint(x: 0, y: 0))) {
            print("scroll")
            self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        collectionTextField.resignFirstResponder()
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

// MARK: - CollectionActionSheetViewControllerDelegate
extension EditCollectionViewController: CollectionActionSheetViewControllerDelegate {
    func handleDismissal() {
        UIView.animate(withDuration: 0.1) {
            self.view.alpha = 1
        }
    }
    
    func handleDismissalBackToCollectionView() {
        UIView.animate(withDuration: 0.1) {
            self.view.alpha = 1
        }
        
        self.backToCollectionView()
    }
}
