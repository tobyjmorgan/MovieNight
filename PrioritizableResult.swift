//
//  PrioritizableResult.swift
//  MovieNight
//
//  Created by redBred LLC on 12/17/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

// allows for a attaching priority to any concrete type that conforms to JSONInitable
public struct PrioritizableResult {
    var priority: ResultPriority
    var movie: Movie
}
