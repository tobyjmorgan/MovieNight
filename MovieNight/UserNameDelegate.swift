//
//  UserNameDelegate.swift
//  MovieNight
//
//  Created by redBred LLC on 12/13/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

protocol UserNameDelegate {
    var currentUserName: String { get }
}

extension Model: UserNameDelegate {
    
    var currentUserName: String {
        
        let users = defaults.array(forKey: UserDefaultsKey.usersArray.rawValue) as! [String]
        
        return users[currentUserIndex]
    }
}
