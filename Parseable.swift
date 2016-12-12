//
//  Parseable.swift
//  MovieNightTest
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

protocol Parseable {
    var parser: (JSON) -> [JSONInitable]? { get }
}

extension TMBDEndpoint: Parseable {
    
    func genresParser(json: JSON) -> [JSONInitable]? {
        
        guard let results = json[Key.genres.rawValue] as? [JSON] else {
            return nil
        }
        
        var genres: [Genre] = []
        
        for result in results {
            
            guard let genre = Genre(json: result) else {
                return nil
            }
            
            genres.append(genre)
        }
        
        return genres
    }
    
    func moviesParser(json: JSON) -> [JSONInitable]? {
        
        guard let results = json[Key.results.rawValue] as? [JSON] else {
            return nil
        }
        
        var items: [Movie] = []
        
        for result in results {
            
            guard let item = Movie(json: result) else {
                print("Problem result: \(result)")
                return nil
            }
            
            items.append(item)
        }
        
        return items
    }
    
    func peopleParser(json: JSON) -> [JSONInitable]? {
        
        guard let results = json[Key.results.rawValue] as? [JSON] else {
            return nil
        }
        
        var items: [Person] = []
        
        for result in results {
            
            guard let item = Person(json: result) else {
                print("Problem result: \(result)")
                return nil
            }
            
            items.append(item)
        }
        
        return items
    }
    
    var parser: (JSON) -> [JSONInitable]? {
        
        switch self {
        case .discover:
            return moviesParser
        case .genres:
            return genresParser
        case .person:
            return peopleParser
        case .movie:
            return moviesParser
        case.popularPeople:
            return peopleParser
        }
    }
}
