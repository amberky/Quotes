//
//  CategoryViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categoryArray = [Category]()
    
    //MARK: - IBOutlet
    @IBOutlet weak var categoryTableView: UITableView!
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        loadCategories()
    }
    
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        categoryTableView.reloadData()
    }
    
    //MARK: - unwind Segue
    @IBAction func backToCategory(_ unwindSegue: UIStoryboardSegue) {}
    
    func bindCategoryAfterSelected(segue: UIStoryboardSegue) {
        let destinationVC = segue.destination as! AddQuoteController
        
        if let indexPath = categoryTableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    func reloadCategoriesAfterAddNew(segue: UIStoryboardSegue) {
        let destinationVC = segue.destination as! AddCategoryController
        destinationVC.dismissHandler = {
            print("loadCategories")
            self.loadCategories()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue identifier: \(segue.identifier ?? "")")
        
        if segue.identifier == "backToCategory" {
            reloadCategoriesAfterAddNew(segue: segue)
        }
        else if segue.identifier == "goToAddCategory" {
            print("Add Category button clicked")
        }
        else {
            bindCategoryAfterSelected(segue: segue)
        }
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
}
