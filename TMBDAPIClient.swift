//
//  TMBDAPIClient.swift
//  MovieNight
//
//  Created by redBred LLC on 12/7/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

// our results for non-id based queries will return pages of results
struct ResultsPage {
    let nextPageURLString: String?
    let results: [JSON]
}

final class TMBDAPIClient: APIClient {
    
    let configuration: URLSessionConfiguration
    
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    
    let apiKey: String
    
    init(config: URLSessionConfiguration, apiKey: String) {
        self.configuration = config
        self.apiKey = apiKey
    }
    
    convenience init(apiKey: String) {
        self.init(config: URLSessionConfiguration.default, apiKey: apiKey)
    }
    
}

//    
//    func fetchRestaurantsFor(location: Coordinate, category: Foursquare.VenueEndpoint.Category, query: String? = nil, searchRadius: Int? = nil, limit: Int? = nil, completion: APIResult<[Venue]> -> Void) {
//        
//        let searchEndpoint = Foursquare.VenueEndpoint.Search(clientID: self.clientID, clientSecret: self.clientSecret, coordinate: location, category: category, query: query, searchRadius: searchRadius, limit: limit)
//        let endpoint = Foursquare.Venues(searchEndpoint)
//        
//        fetch(endpoint, parse: { json -> [Venue]? in
//            
//            guard let venues = json["response"]?["venues"] as? [[String: AnyObject]] else {
//                return nil
//            }
//            
//            return venues.flatMap { venueDict in
//                return Venue(JSON: venueDict)
//            }
//            
//            
//            }, completion: completion)
//    }
//}
