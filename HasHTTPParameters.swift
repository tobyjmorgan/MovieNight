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
        
        let minDate: String
        let maxDate: String

        let currentDate = Date()

        switch self {
            
        case .earliestMovies:
            minDate = "1901-01-01"
            maxDate = "1939-12-31"
            
        case .oldClassics:
            minDate = "1940-01-01"
            maxDate = "1969-12-31"
            
        case .decade70s:
            minDate = "1970-01-01"
            maxDate = "1979-12-31"
            
        case .decade80s:
            minDate = "1980-01-01"
            maxDate = "1989-12-31"
            
        case .decade90s:
            minDate = "1990-01-01"
            maxDate = "1999-12-31"
            
        case .decade2000s:
            minDate = "2000-01-01"
            maxDate = "2009-12-31"

        case .decade2010s:
            minDate = "2010-01-01"
            maxDate = "2019-12-31"

        case .recents:
            
            minDate = currentDate.addingTimeInterval(-1 * 60 * 60 * 24 * 365).description
            maxDate = currentDate.description
            
        case . luckDip:
            minDate = "1900-01-01"
            maxDate = currentDate.description
        }

        return [
            Key.primary_release_date.rawValue + ".gte" : minDate,
            Key.primary_release_date.rawValue + ".lte" : maxDate
        ]
    }
}
