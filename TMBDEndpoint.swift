//
//  TMBDEndpoint.swift
//  MovieNight
//
//  Created by redBred LLC on 12/7/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

typealias ID = Int
typealias PageNumber = Int

enum TMBDEndpoint {
    case genres
    case discover(DiscoverType)
    case popularPeople(PageNumber)
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
            return "/3/person/popular"
            
        case .movie(_), .person(_):
            return "" // TODO: complete these cases
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
            parameters[Key.vote_count.rawValue + ".gte"] = 100
            parameters[Key.sort_by.rawValue] = Key.vote_average.rawValue + ".desc"
            
            switch type {
            
            case .moviesByEra(let era):
                parameters.addValuesFromDictionary(dictionary: era.parameters)
                
            case .moviesByActors(let era, let personIDs):
                if let era = era {
                    parameters.addValuesFromDictionary(dictionary: era.parameters)
                }
                
                let concatenated = String.concatenateWithCommas(arrayOfItems: personIDs)
                parameters[Key.with_people.rawValue] = "\(concatenated)"

            case .moviesByGenres(let era, let genreIDs):
                if let era = era {
                    parameters.addValuesFromDictionary(dictionary: era.parameters)
                }
                
                let concatenated = String.concatenateWithCommas(arrayOfItems: genreIDs)
                parameters[Key.with_genres.rawValue] = "\(concatenated)"
                
                
            case .moviesByGenresActors(let era, let genreIDs, let personIDs):
                if let era = era {
                    parameters.addValuesFromDictionary(dictionary: era.parameters)
                }
                
                if personIDs.count > 0 {
                    
                    let concatenatedPersonIDs = String.concatenateWithCommas(arrayOfItems: personIDs)
                    parameters[Key.with_people.rawValue] = "\(concatenatedPersonIDs)"
                }

                if genreIDs.count > 0 {
                    
                    let concatenatedGenreIDs = String.concatenateWithCommas(arrayOfItems: genreIDs)
                    parameters[Key.with_genres.rawValue] = "\(concatenatedGenreIDs)"
                }
                
            }
            
        case .popularPeople(let page):
            parameters[Key.page.rawValue] = page
            parameters[Key.sort_by.rawValue] = Key.popularity.rawValue + ".desc"
            
        default:
            break
        }
        
        return parameters
    }
}
