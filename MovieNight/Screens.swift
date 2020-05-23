//
//  Screens.swift
//  MovieNight
//
//  Created by redBred LLC on 5/20/20.
//  Copyright © 2020 redBred. All rights reserved.
//

import Foundation
import UIKit

enum Screen: String {
    case setUp
    case editWatcher
    case passDevice
    case preferenceType
    case genericList
    case genericPhotoList
    case processing
    case movieList
    case movieDetail
    case results
}

extension Screen {
    
    var storyboardName: String {
        return "Main"
    }

    var instantiate: UIViewController {
        
        let storyboard = UIStoryboard(name: self.storyboardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: self.rawValue)

        return viewController
    }
}
