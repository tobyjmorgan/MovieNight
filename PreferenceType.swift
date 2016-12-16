//
//  PreferenceType.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

enum PreferenceType: Int {
    case genres
    case eras
    case people
}

extension PreferenceType {
    static var allValues: [PreferenceType] {
        return [.genres, .eras, .people]
    }
}

extension PreferenceType: CustomStringConvertible {
    var description: String {
        switch self {
        case .genres:
            return "Pick Genres"
        case .eras:
            return "Pick Movie Eras"
        case .people:
            return "Pick Movie Stars"
        }
    }
}
