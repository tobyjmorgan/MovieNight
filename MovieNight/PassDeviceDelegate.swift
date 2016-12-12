//
//  PassDeviceDelegate.swift
//  MovieNight
//
//  Created by redBred LLC on 12/11/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

protocol PassDeviceDelegate {
    var wizardUserIndex: Int { get }
    var wizardUsers: [String] { get }
    func onPassDeviceDismiss()
}
