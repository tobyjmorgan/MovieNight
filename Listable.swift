//
//  Listable.swift
//  MovieNight
//
//  Created by redBred LLC on 12/15/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

// allows for a generic table view that can list any Listable item
protocol Listable {
    var uniqueID: Int { get }
    var titleForItem: String { get }
}

extension Genre: Listable {
    var uniqueID: Int {
        return self.id
    }
    
    var titleForItem: String {
        return self.name
    }
}

extension MovieEra: Listable {
    var uniqueID: Int {
        return self.rawValue
    }
    
    var titleForItem: String {
        return self.description
    }
}
