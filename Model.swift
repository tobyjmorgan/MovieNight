//
//  Model.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

enum SelectionMode {
    case preferencesSelection
    case movieSelection
    case done
}

// our simple model
class Model {

    let defaults = UserDefaults.standard
    
    var currentUserIndex: Int
    var userSelections: [UserSelection]
    var selectionMode: SelectionMode = .preferencesSelection
    
    var movieResults: [PrioritizableResult] = []
    
    init?() {
        
        // user defaults must be set up correctly or it will fail
        guard let users = defaults.array(forKey: UserDefaultsKey.usersArray.rawValue) as? [String] else {
            
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

