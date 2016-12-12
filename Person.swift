//
//  Person.swift
//  MovieNight
//
//  Created by redBred LLC on 12/8/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

enum Gender: Int {
    case notListed = 0
    case female
    case male
}

struct Person {
    let id: Int
    let name: String
    let gender: Gender
    let popularity: Double
    let profilePath: String
    let biography: String
}
