//
//  HasHTTPParameters.swift
//  MovieNight
//
//  Created by redBred LLC on 12/7/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

protocol HasHTTPParameters {
    var parameters: HTTPParameters { get }
}

extension MovieEra: HasHTTPParameters {
    var parameters: HTTPParameters {
        
        let minYear: Int
        let maxYear: Int
        
        switch self {
            
        case .earliestMovies:
            minYear = 1
            maxYear = 1939
            
        case .oldClassics:
            minYear = 1940
            maxYear = 1969
            
        case .decade70s:
            minYear = 1970
            maxYear = 1979
            
        case .decade80s:
            minYear = 1980
            maxYear = 1989
            
        case .decade90s:
            minYear = 1990
            maxYear = 1999
            
        case .decade2000s:
            minYear = 2000
            maxYear = 3000
            
        case .recents:
            // get current year
            let currentYear = Date.currentYear()
            
            minYear = currentYear - 1
            maxYear = currentYear
            
        case . luckDip:
            minYear = 1
            maxYear = 3000
        }

        return [
            Key.primary_release_date.rawValue + ".gte" : minYear,
            Key.primary_release_date.rawValue + ".lte" : maxYear
        ]
    }
}
