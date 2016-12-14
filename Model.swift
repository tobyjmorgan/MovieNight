//
//  Model.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

class Model {

    let defaults = UserDefaults.standard
    
    var currentUserIndex: Int
    var userSelections: [UserSelection]
    
    init?() {
        
        guard let users = defaults.array(forKey: UserDefaultsKey.usersArray.rawValue) as? [String],
            users.count > 1 else {
            return nil
        }
        
        var emptyUserSelections: [UserSelection] = []
        
        for _ in users {
            emptyUserSelections.append(UserSelection())
        }
        
        userSelections = emptyUserSelections
        currentUserIndex = 0
    }
}

