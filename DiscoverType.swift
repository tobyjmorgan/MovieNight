//
//  DiscoverType.swift
//  MovieNight
//
//  Created by redBred LLC on 12/7/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

typealias GenreID = Int
typealias PersonID = Int

enum DiscoverType {
    case moviesByGenre(GenreID)
    case moviesByEra(MovieEra)
    case moviesByActor(PersonID)
}
