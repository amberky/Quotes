//
//  CollectionModel.swift
//  Quotes
//
//  Created by Kharnyee Eu on 31/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import UIKit
import CoreData

class CollectionModel {
    let name : String
    let icon : String
    let count : Int
    let isAll: Bool
    var isSelected : Bool
    let objectID : NSManagedObjectID?
    
    init (name: String, icon: String, count: Int = 0, objectID: NSManagedObjectID? = nil, isAll: Bool = false, isSelected: Bool = false) {
        self.name = name
        self.icon = icon
        self.count = count
        self.isSelected = isSelected
        self.isAll = isAll
        self.objectID = objectID
    }
}
