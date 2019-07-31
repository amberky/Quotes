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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var collectionActionSheetService = CollectionActionSheetService()
    
    //MARK: - IBOutlet
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionLabel: UILabel!
    
    @IBOutlet weak var collectionTextField: UITextField!
    
    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    //MARK: Variables
    let iconMode = "-light" // -dark or -light
    lazy var iconArray = IconThemeModel.init(iconMode: iconMode, alpha: 1).iconArray
    
    lazy var unselectedColor = UIColor.mainUnSelected()
    lazy var selectedColor = UIColor.mainSelected()
    
    var selectedIndex = 0
    
    var selectedCollection: CollectionModel?
    
    //MARK: - view delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if selectedCollection != nil {
        doneButton.isEnabled = false
        
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        
        let nib = UINib.init(nibName: "SmallIconCollectionViewCell", bundle: nil)
        iconCollectionView.register(nib, forCellWithReuseIdentifier: "SmallIconCollectionViewCell")
        
        collectionTextField.delegate = self
//        collectionTextField.becomeFirstResponder()
        
        collectionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        let collectionLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionLabelTapped))
        collectionLabel.addGestureRecognizer(collectionLabelTapGesture)
        
        bindValueToComponents()
    }
    
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        checkAndResignFirstResponder()
        
        let collectionActionSheetVC = collectionActionSheetService.show(collection: selectedCollection!)
        collectionActionSheetVC.delegate = self
        self.view.alpha = 0.6;
        self.present(collectionActionSheetVC, animated: true)
    }
    
    func backToCollectionView() {
        performSegue(withIdentifier: "backToCollectionView", sender: self)
    }
    
    //MARK: - unwind Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        checkAndResignFirstResponder()
        
        switch identifier {
        case "doneClicked":
            print("Done bar button clicked")
            
            let trimmedText = collectionTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
            let newIcon = iconArray[selectedIndex].name
            
            if trimmedText != selectedCollection?.name || selectedCollection!.icon != newIcon {
                let updatedCollection = CollectionModel.init(name: trimmedText, icon: iconArray[selectedIndex].name)
                
                let request: NSFetchRequest<Collection> = Collection.fetchRequest()
                request.predicate = NSPredicate(format: "name == %@", selectedCollection!.name)
                
                do {
                    if let collection = try context.fetch(request) as [NSManagedObject]? {
                        if collection.first != nil {
                            collection.first!.setValue(updatedCollection.name, forKey: "name")
                            collection.first!.setValue(updatedCollection.icon, forKey: "icon")
                            
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
    
    //MARK: - functions
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
    
    func checkAndResignFirstResponder() {
        if collectionTextField.isFirstResponder {
            collectionTextField.resignFirstResponder()
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
    
    @objc func collectionLabelTapped() {
        print("collection label tapped")
        DispatchQueue.main.async {
            self.collectionTextField.becomeFirstResponder()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = collectionTextField.text != "" ? true : false
    }
}

extension EditCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        collectionTextField.resignFirstResponder()
        return false
    }
}

extension EditCollectionViewController: CollectionActionSheetViewControllerDelegate {
    func handleDismissal() {
        self.view.alpha = 1
    }
    
    func handleDismissalBackToCollectionView() {
        self.view.alpha = 1
        
//        self.navigationController?.popViewController(animated: true)
        self.backToCollectionView()
    }
}
