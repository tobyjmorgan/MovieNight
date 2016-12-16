//
//  UserSelectionDelegate.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

enum MoveToNextUserResult {
    case readyForNextUser
    case thatWasTheLastOne
}

protocol UserSelectionDelegate {
    var userSelection: UserSelection { get }
    func onMoveOnToNextUser() -> MoveToNextUserResult
    func goingBack()
    var allSelections: [UserSelection] { get }
}

extension Model: UserSelectionDelegate {
    
    var userSelection: UserSelection {
        
        return userSelections[currentUserIndex]
    }
    
    func onMoveOnToNextUser() -> MoveToNextUserResult {
        
        currentUserIndex += 1
        
        if currentUserIndex >= userSelections.count {
            
            // our selection process has completed
            return .thatWasTheLastOne
        }

        // start selection for next user
        return .readyForNextUser
    }
    
    func goingBack() {
        currentUserIndex -= 1
        
        if currentUserIndex < 0 {
            currentUserIndex = 0
        }
    }
    
    var allSelections: [UserSelection] {
        return userSelections
    }

}

