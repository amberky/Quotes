//
//  FailedAddCollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 25/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class FailedAddCollectionViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var containerView: AddEditCollectionView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    //MARK: Variables
    var iconArray = [IconModel]()
    
    let iconMode = "-light" // -dark or -light
    
    let unselectedColor = UIColor.rgb(red: 230, green: 227, blue: 226)
    let selectedColor = UIColor.rgb(red: 170, green: 184, blue: 187)
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        
        containerView.iconCollectionView.delegate = self as UICollectionViewDelegate
        containerView.iconCollectionView.dataSource = self as UICollectionViewDataSource
        
        let nib = UINib(nibName: "SmallIconCollectionViewCell", bundle:nil)
        containerView.iconCollectionView.register(nib, forCellWithReuseIdentifier: "SmallIconCollectionViewCell")
        
        containerView.collectionTextField.delegate = self
        containerView.collectionTextField.becomeFirstResponder()
        
        containerView.collectionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        let collectionLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionLabelTapped))
        
        containerView.collectionLabel.addGestureRecognizer(collectionLabelTapGesture)
        
        print("containerView: \(containerView.frame.width)")
        print("self.view: \(self.view.frame.width)")
        print("iconCollectionView: \(containerView.iconCollectionView.frame.width)")
        
        loadIcon()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "doneClicked":
            print("Done bar button clicked")
            
            let newCollection = Collection(context: self.context)
            newCollection.name = containerView.collectionTextField.text
            newCollection.icon = iconArray[selectedIndex].name
            newCollection.addedOn = Date()
            
            context.insert(newCollection)
            
            saveContext()
            
            let destination = segue.destination as! SelectCollectionViewController
            destination.loadCollections()
        case "cancelClicked":
            print("Cancel bar button clicked")
            
        default:
            print("unknown segue identifier")
        }
    }

    
    @objc func collectionLabelTapped() {
        print("collection label tapped")
        DispatchQueue.main.async {
            self.containerView.collectionTextField.becomeFirstResponder()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = containerView.collectionTextField.text != "" ? true : false
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
    
    func loadIcon() {
        iconArray.append(IconModel.init(iconName: "star", iconImage: UIImage.init(named: "star\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "coffee", iconImage: UIImage.init(named: "coffee\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "fire", iconImage: UIImage.init(named: "fire\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "heart", iconImage: UIImage.init(named: "heart\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "home", iconImage: UIImage.init(named: "home\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "idea", iconImage: UIImage.init(named: "idea\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "smile", iconImage: UIImage.init(named: "smile\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "sun", iconImage: UIImage.init(named: "sun\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "thumbs-up", iconImage: UIImage.init(named: "thumbs-up\(iconMode)")!))
        iconArray.append(IconModel.init(iconName: "toolbox", iconImage: UIImage.init(named: "toolbox\(iconMode)")!))
    }
}

extension FailedAddCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        containerView.collectionTextField.resignFirstResponder()
        return false
    }
}

extension FailedAddCollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //NOTE: - Space between cell is 10pt, therefore deduct 50pt
        
        let width = (containerView.frame.width - 50) / 5
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
        if
            containerView.collectionTextField.isFirstResponder {
            containerView.collectionTextField.resignFirstResponder()
        }
        
        let icon = iconArray[indexPath.row]
        print(icon.name)
        
        selectedIndex = indexPath.row
        collectionView.reloadData()
    }
}
