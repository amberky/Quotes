//
//  AddCategoryController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class AddCategoryController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - IBOutlet
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    //MARK: Variables
    var iconArray = [IconModel]()
    
    let iconMode = "-light" // -dark or -light
    
    let unselectedColor = UIColor.rgb(red: 230, green: 227, blue: 226)
    let selectedColor = UIColor.rgb(red: 170, green: 184, blue: 187)
    
    var selectedIndex = 0
    
    //MARK: - view delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        
        categoryTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        let categoryLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryLabelTapped))
        categoryLabel.addGestureRecognizer(categoryLabelTapGesture)
        
        loadIcon()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "doneClicked":
            let newCategory = Category(context: self.context)
            newCategory.name = categoryTextField.text
            newCategory.icon = iconArray[selectedIndex].name
            
            context.insert(newCategory)
            
            saveContext()
            
            print("Done bar button clicked")
            
            let destination = segue.destination as! CategoryViewController
            destination.loadCategories()
            
            
        case "cancelClicked":
            print("Cancel bar button clicked")
            
        default:
            print("unexpected segue identifier")
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
    
    @objc func categoryLabelTapped() {
        print("category label tapped")
        DispatchQueue.main.async {
            self.categoryTextField.becomeFirstResponder()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = categoryTextField.text != "" ? true : false
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

extension AddCategoryController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryIconCollectionCell", for: indexPath) as! CategoryIconCollectionViewCell
        cell.iconImage.image = iconArray[indexPath.row].image
        
        cell.backgroundColor = selectedIndex == indexPath.row ? selectedColor : unselectedColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let icon = iconArray[indexPath.row]
        print(icon.name)
        
        selectedIndex = indexPath.row
        collectionView.reloadData()
    }
}
