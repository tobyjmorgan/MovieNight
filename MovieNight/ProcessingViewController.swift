//
//  ProcessingViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/18/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

protocol ProcessingNavDelegate: NavDelegate {
    func onNextStepProcessing()
}

protocol ProcessingDataDelegate: DataDelegate {
    func assignMeAsProcessingCompletedDelegate(delegate: ProcessingCompletedDelegate)
    func processSelections()
}

public protocol ProcessingCompletedDelegate: class {
    func onProcessingCompleted()
}

class ProcessingViewController: UIViewController, CAAnimationDelegate {

    @IBOutlet var eggTimerView: UIView!
    @IBOutlet var bigWheel: UIView!
    @IBOutlet var mediumWheel: UIView!
    @IBOutlet var littleWheel: UIView!
    @IBOutlet var tinyWheel: UIView!
    @IBOutlet var processingLabel: UILabel!
    @IBOutlet var errorView: UIView!

    weak var navDelegate: ProcessingNavDelegate?
    weak var dataDelegate: ProcessingDataDelegate?
    
    let dispatchGroup = DispatchGroup()
    
    let client = TMBDAPIClient()

    let spinDuration = 3.0
    let rotation = CGFloat(6.0 * Double.pi/2)
    var animationsOn: Bool = true {
        didSet {
            if !animationsOn {
                
                stopSpinAnimation()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        errorView.layer.cornerRadius = 150
        
        bigWheel.layer.cornerRadius = 150
        mediumWheel.layer.cornerRadius = 115
        littleWheel.layer.cornerRadius = 80
        tinyWheel.layer.cornerRadius = 45
        
        startSpinAnimation()
        fadeLabelOut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.dataDelegate?.assignMeAsProcessingCompletedDelegate(delegate: self)
            self.dataDelegate?.processSelections()
        }
              
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // toggling the appearance of the navigation bar
    // Thanks to Michael Garito on StackOverflow for this
    // http://stackoverflow.com/questions/29209453/how-to-hide-a-navigation-bar-from-first-viewcontroller-in-swift
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

    
    
    ////////////////////////////////////////////////////
    // MARK: pretty animations stuff
    
    func startSpinAnimation() {
        
        // spinning wheels animation
        bigWheel.rotationAnimation(rotation: rotation, duration: spinDuration, completionDelegate: self)
        mediumWheel.rotationAnimation(rotation: -rotation, duration: spinDuration)
        littleWheel.rotationAnimation(rotation: rotation, duration: spinDuration)
        tinyWheel.rotationAnimation(rotation: -rotation, duration: spinDuration)
    }
    
    func stopSpinAnimation() {
        bigWheel.layer.removeAllAnimations()
        mediumWheel.layer.removeAllAnimations()
        littleWheel.layer.removeAllAnimations()
        tinyWheel.layer.removeAllAnimations()
    }
    
    func fadeLabelIn() {
        
        if animationsOn {
            
            UIView.animate(withDuration: 0.5, animations: { self.processingLabel.alpha = 1.0 }) {[weak self] bool in
                self?.fadeLabelOut()
            }
        }
    }
    
    func fadeLabelOut() {
        
        if animationsOn {
            
            UIView.animate(withDuration: 0.5, animations: { self.processingLabel.alpha = 0.0 }) {[weak self] bool in
                self?.fadeLabelIn()
            }
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if animationsOn {
            startSpinAnimation()
        }
    }
}

extension ProcessingViewController: ProcessingCompletedDelegate {
    
    func onProcessingCompleted() {
        stopSpinAnimation()
        navDelegate?.onNextStepProcessing()
    }
}
