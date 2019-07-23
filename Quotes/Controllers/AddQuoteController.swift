//
//  AddQuoteController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class AddQuoteController: UIViewController, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var quoteTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var categoryArray = [Category]()
    var selectedCategory : Category? {
        didSet {
            print("didSet")
            setSelectedCategory()
        }
    }
    
    var dismissHandler: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        quoteTextField.delegate = self

        quoteTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        let quoteLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(quoteLabelTapped))
        quoteLabel.addGestureRecognizer(quoteLabelTapGesture)
        
        
        let authorLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(authorLabelTapped))
        authorLabel.addGestureRecognizer(authorLabelTapGesture)
        
    }
    
    func setSelectedCategory() {
        print("selectedCategory: \(selectedCategory?.name ?? "nil")")
        if selectedCategory != nil {
            categoryButton.setTitle(selectedCategory?.name ?? "" , for: .normal)
        }
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
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        let newQuote = Quote(context: self.context)
        newQuote.quote = quoteTextField.text!
        newQuote.author = authorTextField?.text ?? ""
        newQuote.category = selectedCategory
        
        context.insert(newQuote)
        
        saveContext()
        
        dismiss(animated: true) {
            self.dismissHandler()
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
    
    func mockData() {
        let newCategory = Category(context: self.context)
        newCategory.name = "None"
        newCategory.icon = ""
        
        let newCategory1 = Category(context: self.context)
        newCategory1.name = "Work"
        newCategory1.icon = ""
        
        let newCategory2 = Category(context: self.context)
        newCategory2.name = "Motivation"
        newCategory2.icon = ""
        
        let newCategory3 = Category(context: self.context)
        newCategory3.name = "Steve Jobs"
        newCategory3.icon = ""
        
        let newCategory4 = Category(context: self.context)
        newCategory4.name = "Others"
        newCategory4.icon = ""
        
        categoryArray.append(newCategory)
        categoryArray.append(newCategory1)
        categoryArray.append(newCategory2)
        categoryArray.append(newCategory3)
        categoryArray.append(newCategory4)
        
        saveContext()
        
        //categoryPicker.reloadAllComponents()
    }
    
    func deleteData() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let dataToBeDeleted = try context.fetch(request)
            
            for i in dataToBeDeleted
            {
                context.delete(i)
            }
            
            try context.save()
            
        } catch {
            
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        doneButton.isEnabled = quoteTextField.text != "" ? true : false
        print(quoteTextField.text ?? "")
    }
    
    //MARK: - Segue
    @IBAction func backToAdd(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func backToAddWithCategory(_ unwindSegue: UIStoryboardSegue) {}
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destinationVC = segue.destination as! QuoteViewController
//
//        destinationVC.loadQuotes()
//    }
}
