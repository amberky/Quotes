//
//  AddQuoteController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class AddQuoteController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var categoryPopover: UIView!
    
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    let pickerView = UIPickerView()
    
    var categoryArray = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCategories()
        
        initComponents()
    }
    
    func initComponents() {
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        
        categoryTextField.inputView = categoryPicker
    }
    
    func getCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryArray = try context.fetch(request)
            
            if categoryArray.count == 0 {
                let newCategory = Category(context: self.context)
                newCategory.name = "None"
                newCategory.icon = ""
                
                saveContext()
                
                categoryArray.append(newCategory)
            }
            
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    func saveContext() {
        do {
            try context.save()
            pickerView.reloadAllComponents()
            
        } catch {
            print("Error saving data from context \(error)")
        }
    }
}

extension AddQuoteController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categoryArray[row].name
    }
}
