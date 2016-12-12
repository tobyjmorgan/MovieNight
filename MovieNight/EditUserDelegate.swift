//
//  EditUserDelegate.swift
//  MovieNight
//
//  Created by redBred LLC on 12/11/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

protocol EditUserDelegate {
    var userName: String { get }
    func onDismissEditUser(newName: String)
}
