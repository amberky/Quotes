//
//  AddCollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class AddCollectionViewController: UIViewController {
    
    // MARK: Variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var maxLength: Int = 50
    
    let iconMode = "-light" // -dark or -light
    lazy var iconArray = IconThemeModel.init(iconMode: iconMode, alpha: 1).iconArray
    
    lazy var unselectedColor = UIColor.mainUnSelected()
    lazy var selectedColor = UIColor.mainSelected()
    
    var selectedIndex = 0
    
    // MARK: - IBOutlet
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionLabel: UILabel!
    
    @IBOutlet weak var collectionTextField: UITextField!
    
    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        
        let nib = UINib.init(nibName: "SmallIconCollectionViewCell", bundle: nil)
        iconCollectionView.register(nib, forCellWithReuseIdentifier: "SmallIconCollectionViewCell")

        collectionTextField.delegate = self
        collectionTextField.becomeFirstResponder()

        collectionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

        setupGesture()
        setupNotificationCenter()
    }
    
    // MARK: - Objc Functions
    @objc func collectionLabelTapped() {
        print("collection label tapped")
        DispatchQueue.main.async {
            self.collectionTextField.becomeFirstResponder()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = collectionTextField.text?.trimmingCharacters(in: .whitespaces) != "" ? true : false
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        
        guard let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let estimatedHeight = kbSize.height + 20
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: estimatedHeight, right: 0)
            
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
    
    // MARK: - Functions
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
                return true
            } else {
                return false
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
    
    // MARK: - Unwind Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        print("prepare")
        
        checkAndResignFirstResponder()
        
        switch identifier {
        case "doneClicked":
            let collectionName = (collectionTextField.text ?? "").trimmingCharacters(in: .whitespaces)
            
            let newCollection = Collection(context: self.context)
            newCollection.name = collectionName
            newCollection.icon = iconArray[selectedIndex].name
            newCollection.addedOn = Date()
            newCollection.updatedOn = Date()
            
            context.insert(newCollection)
            
            saveContext()
            
            if segue.destination is SelectCollectionViewController {
                let destination = segue.destination as! SelectCollectionViewController
                destination.loadCollections()
                destination.selectedCollection.append(newCollection)
            } else { return }
            
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
            let collectionName = (collectionTextField.text ?? "").trimmingCharacters(in: .whitespaces)
            
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
extension AddCollectionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        collectionTextField.resignFirstResponder()
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

// MARK: - UICollectionViewDelegate
extension AddCollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        //NOTE: - Space between cell is 10pt, therefore deduct 50pt

        let width = (collectionView.frame.width - 50) / 5
        let height = width

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmallIconCollectionViewCell", for: indexPath) as! SmallIconCollectionViewCell

        cell.iconImage.image = iconArray[indexPath.row].image

        cell.iconBackground.backgroundColor = selectedIndex == indexPath.row ? selectedColor : unselectedColor
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionTextField.isFirstResponder {
            collectionTextField.resignFirstResponder()
        }

//        let icon = iconArray[indexPath.row]

        selectedIndex = indexPath.row
        collectionView.reloadData()
    }
}
