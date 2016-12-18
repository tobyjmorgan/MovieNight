//
//  PhotoListable.swift
//  MovieNight
//
//  Created by redBred LLC on 12/15/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

// allows for a generic table view that can list any PhotoListable item
protocol PhotoListable: Listable {
    var photoURL: String { get }
}

extension Person: PhotoListable {
    var uniqueID: Int {
        return self.id
    }
    
    var titleForItem: String {
        return self.name
    }
    
    var photoURL: String {
        return self.profilePath
    }
}
