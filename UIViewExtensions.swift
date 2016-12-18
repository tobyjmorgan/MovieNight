//
//  UIViewExtensions.swift
//  MovieNight
//
//  Created by redBred LLC on 12/16/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func myWhiteBorder() {
        
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.white.cgColor

    }
}
