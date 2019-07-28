//
//  collectionModel.swift
//  Quotes
//
//  Created by Kharnyee Eu on 24/07/2019.
//  Copyright © 2019 focus. All rights reserved.
//

import Foundation

class CollectionModel {
    let name : String
    let icon : String
    let isAll: Bool
    var isSelected : Bool
    
    init (collectionName: String, collectionIcon: String, showAll: Bool = false, selected: Bool = false) {
        name = collectionName
        icon = collectionIcon
        isSelected = selected
        isAll = showAll
    }
}
