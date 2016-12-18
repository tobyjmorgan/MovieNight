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
    case moviesByGenresActors(MovieEra?, [GenreID], [PersonID])
    case moviesByGenres(MovieEra?, [GenreID])
    case moviesByActors(MovieEra?, [PersonID])
    case moviesByEra(MovieEra)
}
