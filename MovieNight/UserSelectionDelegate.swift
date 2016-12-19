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
    var allSelections: [UserSelection] { get }
    var selectionMode: SelectionMode { get }
    var movieResults: [PrioritizableResult] { get set }
    
    func goToNextStep()
    func goBackToPreviouStep()
    func goToFirstStep()
}

extension Model: UserSelectionDelegate {
    
    var userSelection: UserSelection {
        return userSelections[currentUserIndex]
    }
    
    var allSelections: [UserSelection] {
        return userSelections
    }
    
    func goToNextStep() {
        
        // check to see if we would go beyond the last user
        if currentUserIndex == allSelections.count - 1 {
            
            // check to see what mode we are in
            if selectionMode == .preferencesSelection {
                
                // move to the next mode
                selectionMode = .movieSelection
                currentUserIndex = 0
                
            } else {
                
                // we are done!
                selectionMode = .done
            }
            
        } else {
            
            // increment to the next user
            currentUserIndex += 1
        }
    }
    
    func goBackToPreviouStep() {
        
        if selectionMode == .done {
            
            currentUserIndex = allSelections.count-1
            selectionMode = .movieSelection
            
        } else {
            
            currentUserIndex -= 1
            
            if currentUserIndex < 0 {
                
                if selectionMode == .movieSelection {
                    
                    currentUserIndex = allSelections.count-1
                    selectionMode = .preferencesSelection
                    movieResults = []
                    
                } else {
                
                    currentUserIndex = 0
                }
            }
        }        
    }
    
    func goToFirstStep() {
        currentUserIndex = 0
        selectionMode = .preferencesSelection
        movieResults = []
    }
}

