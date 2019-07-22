//
//  categoryModel.swift
//  Quotes
//
//  Created by Kharnyee Eu on 22/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import Foundation

class CategoryModel {
    let name : String
    let icon : String
    let isCreateNew : Bool
    
    init (categoryName: String, categoryIcon: String, isNew: Bool = false) {
        name = categoryName
        icon = categoryIcon
        isCreateNew = isNew
    }
}
