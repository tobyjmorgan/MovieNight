//
//  UserSelectionDelegate.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

protocol UserSelectionDelegate {
    var userSelection: UserSelection { get }
    func onUserCompletedMakingSelections()
}

extension Model: UserSelectionDelegate {
    
    var userSelection: UserSelection {
        
        return userSelections[currentUserIndex]
    }
    
    func onUserCompletedMakingSelections() {
        
        currentUserIndex += 1
        
        if currentUserIndex >= userSelections.count {
            
            // our selection process has completed
            
        } else {
            
            // start selection for next user
        }
    }
}

