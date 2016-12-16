//
//  PhotoListable.swift
//  MovieNight
//
//  Created by redBred LLC on 12/15/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

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
