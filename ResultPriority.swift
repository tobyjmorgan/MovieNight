//
//  ResultPriority.swift
//  MovieNight
//
//  Created by redBred LLC on 12/17/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation
import UIKit

enum ResultPriority: Int {
    case matchOnAllCriteria
    case matchOnAllPeople
    case matchOnOnePerson
    case matchOnAllGenres
    case matchOnOneGenre
}

extension ResultPriority {
    var color: UIColor {
        
        switch self {
            
        case .matchOnAllCriteria:
            return UIColor.red.withAlphaComponent(0.5)
            
        case .matchOnAllPeople:
            return UIColor.orange.withAlphaComponent(0.4)
            
        case .matchOnOnePerson:
            return UIColor.yellow.withAlphaComponent(0.3)
            
        case .matchOnAllGenres:
            return UIColor.green.withAlphaComponent(0.1)
            
        case .matchOnOneGenre:
            return UIColor.clear
        }
    }
}

