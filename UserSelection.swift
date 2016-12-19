//
//  UserSelection.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

class UserSelection {
    var selectedGenres: [Genre] = []
    var selectedEras: [MovieEra] = []
    var selectedPeople: [Person] = []
    var selectedResults: [PrioritizableResult] = []
}

extension UserSelection: CustomStringConvertible {

    var selectedGenresDescription: String {
        
        var descriptionString = ""
        
        for genre in selectedGenres {
            
            if descriptionString == "" {
                
                descriptionString += "\(genre.name)"
            } else {
                
                descriptionString += ", \(genre.name)"
            }
        }
        
        return descriptionString
    }
    
    var selectedErasDescription: String {
        
        var descriptionString = ""
        
        for era in selectedEras {
            
            if descriptionString == "" {
                
                descriptionString += "\(era.description)"
            } else {
                
                descriptionString += ", \(era.description)"
            }
        }
        
        return descriptionString
    }
    
    var selectedPeopleDescription: String {
        
        var descriptionString = ""
        
        for person in selectedPeople {
            
            if descriptionString == "" {
                
                descriptionString += "\(person.name)"
            } else {
                
                descriptionString += ", \(person.name)"
            }
        }
        
        return descriptionString
    }
    
    var description: String {
        
        var returnString = ""
        
        if selectedGenresDescription != "" ||
            selectedErasDescription != "" ||
            selectedPeopleDescription != "" {
            
            returnString += "Selections:\n\n"
        }
        
        if selectedGenresDescription != "" {
            returnString += "\(selectedGenresDescription)\n"
        }
        
        if selectedErasDescription != "" {
            returnString += "\(selectedErasDescription)\n"
        }

        if selectedPeopleDescription != "" {
            returnString += "\(selectedPeopleDescription)\n"
        }

        return returnString
    }
}

