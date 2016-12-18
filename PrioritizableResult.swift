//
//  PrioritizableResult.swift
//  MovieNight
//
//  Created by redBred LLC on 12/17/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

// allows for a attaching priority to any concrete type that conforms to JSONInitable
struct PrioritizableResult {
    var priority: ResultPriority
    var resultObject: JSONInitable
}

// we will be using it to display movies
extension PrioritizableResult {
    var movie: Movie {
        return resultObject as! Movie
    }
}
