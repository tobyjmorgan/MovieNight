//
//  MovieEra.swift
//  MovieNight
//
//  Created by redBred LLC on 12/7/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

enum MovieEra: Int {
    case recents
    case decade2010s
    case decade2000s
    case decade90s
    case decade80s
    case decade70s
    case oldClassics
    case earliestMovies
    case luckDip
}

extension MovieEra {
    static var allValues: [MovieEra] {
        return [.recents, .decade2010s, .decade2000s, .decade90s, .decade80s, .decade70s, .oldClassics, .earliestMovies, .luckDip]
    }
}

extension MovieEra: CustomStringConvertible {
    var description: String {
        switch self {
        case .recents:
            return "Recent Movies"
        case .decade2010s:
            return "Movies of the 2010s"
        case .decade2000s:
            return "Movies of the 2000s"
        case .decade90s:
            return "90s Movies"
        case .decade80s:
            return "80s Movies"
        case .decade70s:
            return "70s Movies"
        case .oldClassics:
            return "Old Classics"
        case .earliestMovies:
            return "Earliest Movies"
        case .luckDip:
            return "Lucky Dip"
        }
    }
}

