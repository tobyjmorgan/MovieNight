//
//  PassDeviceViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/11/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

protocol PassDeviceNavDelegate: NavDelegate {
    func onNextStepPassDevice()
}

protocol PassDeviceDataDelegate: DataDelegate {
    var currentUserName: String { get }
    
    func goBackToPreviousSelectionStep()
}

class PassDeviceViewController: UIViewController {

    weak var navDelegate: PassDeviceNavDelegate?
    weak var dataDelegate: PassDeviceDataDelegate?
    
    @IBOutlet var passDeviceLabel: UILabel!
    @IBOutlet var buttonView: UIView!
    
    @IBAction func onNextStep() {
        
        navDelegate?.onNextStepPassDevice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // remove the processing view controller from the view stack
        if var controllers = navigationController?.viewControllers {
            
            let lastButOneIndex = controllers.count-2
            
            if let _ = controllers[lastButOneIndex] as? ProcessingViewController {
                controllers.remove(at: lastButOneIndex)
                navigationController?.viewControllers = controllers
            }
        }
        
        if let name = dataDelegate?.currentUserName {
            
            passDeviceLabel.text = "Pass device to\n\(name)"
            buttonView.isHidden = false
            
        } else {
            
            // notify there was a problem and no button
            passDeviceLabel.text = "Hmm. There was a problem. Try going back."
            buttonView.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Thanks to shreena shah for this neat way of hooking in to the back button
    // http://stackoverflow.com/a/32667598
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            // switch back to previous user in the model
            dataDelegate?.goBackToPreviousSelectionStep()
        }
    }
}
