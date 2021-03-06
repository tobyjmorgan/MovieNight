//
//  APIClient.swift
//  MovieNight
//
//  Created by redBred LLC on 12/7/16.
//  Copyright © 2016 redBred. All rights reserved.
//

// Many thanks to Pasan Premaratne, who provided most of this code in his Treehouse courses

import Foundation

typealias HTTPKey = String
typealias HTTPParameters = [HTTPKey : Any]
typealias JSON = [HTTPKey : Any]
typealias JSONTask = URLSessionDataTask
typealias JSONTaskCompletion = (JSON?, HTTPURLResponse?, APIClientError?) -> Void

enum APIClientError: Error {
    case missingHTTPResponse
    case noDataReturned(Error?)
    case unexpectedHTTPResponseStatusCode(Int)
    case unableToSerializeDataToJSON(Error)
    case unableToParseJSON(JSON)
    case unknownError
}

enum APIResult<T> {
    case success(T)
    case failure(Error)
}

// all the elements we need to get to an API endpoint
protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var parameters: HTTPParameters { get }
}

extension Endpoint {
    
    // provide parameters in URLQueryItem form
    var queryComponents: [URLQueryItem] {
        var components = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.append(queryItem)
        }
        
        return components
    }
    
    // provide a request utilizing all the elements of the Endpoint
    var request: URLRequest {
        var components = URLComponents(string: baseURL)!
        components.path = path
        components.queryItems = queryComponents
        
        let url = components.url!
        
        print(url.absoluteString)
        return URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
    }
}

// anything that can be instantiated from JSON (failable intializer)
protocol JSONInitable {
    init?(json: JSON)
}


protocol APIClient {
    var configuration: URLSessionConfiguration { get }
    var session: URLSession { get }
        
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask
    func fetch<T: JSONInitable>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void)
}

extension APIClient {
    
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask {

        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let response = response as? HTTPURLResponse else {
                completion(nil, nil, APIClientError.missingHTTPResponse)
                return
            }
            
            guard let data = data else {
                completion(nil, response, APIClientError.noDataReturned(error))
                return
            }

            switch response.statusCode {
            
            case 200:
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON
                    completion(json, response, nil)
                } catch let error {
                    completion(nil, response, APIClientError.unableToSerializeDataToJSON(error))
                }
            
            default:
                completion(nil, response, APIClientError.unexpectedHTTPResponseStatusCode(response.statusCode))
                return
            }
        }
        
        return task
    }
    
    func fetch<T: JSONInitable>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) {
        
        let task = JSONTaskWithRequest(request: request) { (json, response, error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIClientError.unknownError))
                    }
                    return
                }
                
                if let value = parse(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(APIClientError.unableToParseJSON(json)))
                }
            }
        }
        
        task.resume()
    }
    
    func fetch(endpoint: Endpoint, parse: @escaping (JSON) -> [JSONInitable]?, completion: @escaping (APIResult<[JSONInitable]>) -> Void) {
        
        let request = endpoint.request
        
        let task = JSONTaskWithRequest(request: request) { (json, response, error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIClientError.unknownError))
                    }
                    return
                }
                
                if let value = parse(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(APIClientError.unableToParseJSON(json)))
                }
            }
        }
        
        task.resume()
    }
}
