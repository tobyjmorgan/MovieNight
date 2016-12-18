//
//  Movie.swift
//  MovieNight
//
//  Created by redBred LLC on 12/7/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

struct Movie {
    let id: Int
    let title: String
    let genreIDs: [Int]
    let overview: String
    let releaseDate: Date
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let posterPath: String
}

extension Movie: Equatable {}

func ==(lhs: Movie, rhs: Movie) -> Bool {
    return lhs.id == rhs.id
}
