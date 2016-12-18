//
//  StringExtensions.swift
//  MovieNight
//
//  Created by redBred LLC on 12/16/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

extension String {
    
    static func concatenateWithCommas(arrayOfItems: [CustomStringConvertible]) -> String {
        
        var returnString = ""
        
        for item in arrayOfItems {
            
            if returnString == "" {
                
                returnString += "\(item)"
                
            } else {
                
                returnString += ", \(item)"
            }
        }
        
        return returnString
    }
}
