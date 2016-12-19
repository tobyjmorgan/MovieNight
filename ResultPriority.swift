//
//  ResultPriority.swift
//  MovieNight
//
//  Created by redBred LLC on 12/17/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation
import UIKit

// used to drive the "heat map" color coding of the results
enum ResultPriority: Int {
    case matchOnAllCriteria
    case matchOnAllPeople
    case matchOnOnePerson
    case matchOnAllGenres
    case matchOnOneGenre
    case matchOnOneEra
}

extension ResultPriority {
    static var allValues: [ResultPriority] {
        return [.matchOnAllCriteria, .matchOnAllPeople, .matchOnOnePerson, .matchOnAllGenres, .matchOnOneGenre, .matchOnOneEra]
    }
}
extension ResultPriority {
    var color: UIColor {
        
        switch self {
            
        case .matchOnAllCriteria:
            return UIColor.red.withAlphaComponent(0.3)
            
        case .matchOnAllPeople:
            return UIColor.orange.withAlphaComponent(0.2)
            
        case .matchOnOnePerson:
            return UIColor.yellow.withAlphaComponent(0.1)
            
        case .matchOnAllGenres:
            return UIColor.green.withAlphaComponent(0.1)
            
        case .matchOnOneGenre:
            return UIColor.clear
            
        case .matchOnOneEra:
            return UIColor.clear
        }
        
    }
}

