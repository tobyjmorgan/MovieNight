//
//  TMBDEndpoint.swift
//  MovieNight
//
//  Created by redBred LLC on 12/7/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

typealias ID = Int

enum TMBDEndpoint {
    case genres
    case discover(DiscoverType)
    case popularPeople
    case movie(ID)
    case person(ID)
}

extension TMBDEndpoint: Endpoint {
    
    var apiKey: String {
        return "3df2c1a414da9b780d72892bc0091e18"
    }
    
    var baseURL: String {
        return "https://api.themoviedb.org"
    }
    
    var path: String {
        
        switch self {
            
        case .genres:
            return "/3/genre/movie/list"
            
        case .discover(_):
            return "/3/discover/movie"
            
        case .popularPeople:
            return "/3/people/popular"
            
        case .movie(_), .person(_):
            return "" // TODO: coplete these cases
        }
    }
    
    var parameters: HTTPParameters {
        
        var parameters: HTTPParameters = [:]
        
        // always need the api key
        parameters[Key.api_key.rawValue] = apiKey
        
        switch self {
            
        case .discover(let type):

            // keeping it clean!
            parameters[Key.include_adult.rawValue] = false
            parameters[Key.release_date.rawValue + ".gte"] = "1900-01-01"
            parameters[Key.vote_count.rawValue + ".gte"] = 100
            parameters[Key.sort_by.rawValue] = Key.vote_average.rawValue + ".desc"
            
            switch type {
            
            case .moviesByEra(let eras):
                for era in eras {
                    parameters.addValuesFromDictionary(dictionary: era.parameters)
                }
                
            case .moviesByGenre(let genres):
                
                var genresList = ""
                
                for genre in genres {
                    if genresList == "" {
                        genresList += "\(genre.id)"
                    } else {
                        genresList += ", \(genre.id)"
                    }
                }

                parameters[Key.with_genres.rawValue] = genresList
            }
            
        case .popularPeople:
            parameters[Key.sort_by.rawValue] = Key.popularity.rawValue + ".desc"
            
        default:
            break
        }
        
        return parameters
    }
}
