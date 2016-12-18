//
//  PrioritizableResult.swift
//  MovieNight
//
//  Created by redBred LLC on 12/17/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

struct PrioritizableResult {
    var priority: ResultPriority
    var resultObject: JSONInitable
}

extension PrioritizableResult {
    var movie: Movie {
        return resultObject as! Movie
    }
}
