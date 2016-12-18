//
//  PreferenceType.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

enum PreferenceType: Int {
    case eras
    case genres
    case people
}

extension PreferenceType {
    static var allValues: [PreferenceType] {
        return [.eras, .genres, .people]
    }
}

extension PreferenceType: CustomStringConvertible {
    var description: String {
        switch self {
        case .eras:
            return "Pick Movie Eras"
        case .genres:
            return "Pick Genres"
        case .people:
            return "Pick Stars"
        }
    }
}
