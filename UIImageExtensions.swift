//
//  UIImageExtensions.swift
//  MovieNight
//
//  Created by redBred LLC on 12/15/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    static var photoRootPath: String {
        
        if let photoPath = UserDefaults.standard.value(forKey: UserDefaultsKey.photoRootPath.rawValue) as? String {
            return photoPath
        }
        
        return ""
    }
    

    static func getImageAsynchronously(urlString: String?, completion: @escaping (UIImage) -> ()) {
        
        if let urlString = urlString,
           let url = URL(string: photoRootPath + urlString) {
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                DispatchQueue.main.async {
                    
                    guard let response = response as? HTTPURLResponse,
                          let data = data,
                          response.statusCode == 200,
                          let image = UIImage(data: data) else {
                            
                        return
                    }
                    
                    completion(image)
                }
            }
            
            task.resume()
        }
    }
}

