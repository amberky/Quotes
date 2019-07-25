//
//  AddCollectionViewController.swift
//  Quotes
//
//  Created by Kharnyee Eu on 25/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class AddCollectionViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCollectionView()
        
    }
    
    func addCollectionView(){
        let cv = AddEditCollectionViewController(nibName: "AddEditCollectionViewController", bundle: nil)
        self.view.addSubview(cv.view)
        self.addChild(cv)
        
    }
}
