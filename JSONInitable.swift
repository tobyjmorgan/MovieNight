//
//  JSONInitable.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

extension Genre: JSONInitable {
    init?(json: JSON) {
        
        guard let id    = json[Key.id.rawValue] as? Int,
            let name  = json[Key.name.rawValue] as? String else {
                return nil
        }
        
        self.id = id
        self.name = name
    }
}

extension Movie: JSONInitable {
    init?(json: JSON) {
        
        guard let id                = json[Key.id.rawValue] as? Int,
            let title             = json[Key.title.rawValue] as? String,
            let genreIDs          = json[Key.genre_ids.rawValue] as? [Int],
            let overview          = json[Key.overview.rawValue] as? String,
            let releaseDateString = json[Key.release_date.rawValue] as? String,
            let voteAverage       = json[Key.vote_average.rawValue] as? Double,
            let voteCount         = json[Key.vote_count.rawValue] as? Int,
            let popularity        = json[Key.popularity.rawValue] as? Double,
            let posterPath        = json[Key.poster_path.rawValue] as? String else {
                return nil
        }
        
        guard let releaseDate = Date.getDateFromStringYYYY_MM_DD(stringDate: releaseDateString) else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.genreIDs = genreIDs
        self.overview = overview
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.posterPath = posterPath
    }
}

extension Person: JSONInitable {
    init?(json: JSON) {
        guard let id = json[Key.id.rawValue] as? Int,
            let name = json[Key.name.rawValue] as? String,
            let popularity = json[Key.popularity.rawValue] as? Double,
            let profilePath = json[Key.profile_path.rawValue] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.popularity = popularity
        self.profilePath = profilePath
    }
}
