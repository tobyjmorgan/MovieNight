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
    
    init(config: URLSessionConfiguration) {
        self.configuration = config
    }
    
    convenience init() {
        self.init(config: URLSessionConfiguration.default)
    }
    
}

