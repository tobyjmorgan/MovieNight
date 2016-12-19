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

// adapted from code by Andrew Bancroft
// https://www.andrewcbancroft.com/2014/10/15/rotate-animation-in-swift/
extension UIView {
    
    // rotation transform animation on a UIView
    func rotationAnimation(rotation: CGFloat, duration: CFTimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = nil) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = rotation
        rotateAnimation.duration = duration
        
        if let delegate = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
