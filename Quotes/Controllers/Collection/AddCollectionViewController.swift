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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
    
    //MARK: - view delegate
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

        let collectionLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionLabelTapped))
        collectionLabel.addGestureRecognizer(collectionLabelTapGesture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        checkAndResignFirstResponder()
        
        switch identifier {
        case "doneClicked":
            checkAndResignFirstResponder()

            let newCollection = Collection(context: self.context)
            newCollection.name = (collectionTextField.text ?? "").trimmingCharacters(in: .whitespaces)
            newCollection.icon = iconArray[selectedIndex].name
            newCollection.addedOn = Date()
            
            context.insert(newCollection)

            saveContext()

            if segue.destination is SelectCollectionViewController {
                let destination = segue.destination as! SelectCollectionViewController
                destination.loadCollections()
            } else { return }
            
        case "cancelClicked":
            print("Cancel bar button clicked")

        default:
            print("unknown segue identifier")
        }
    }

    //MARK: - functions
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
        doneButton.isEnabled = collectionTextField.text?.trimmingCharacters(in: .whitespaces) != "" ? true : false
    }
    
    func checkAndResignFirstResponder() {
        if collectionTextField.isFirstResponder {
            collectionTextField.resignFirstResponder()
        }
    }
}

extension AddCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        collectionTextField.resignFirstResponder()
        return false
    }
}

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
