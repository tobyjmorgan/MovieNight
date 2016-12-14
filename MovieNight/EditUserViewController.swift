//
//  EditUserViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/11/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class EditUserViewController: UIViewController {

    var delegate: EditUserDelegate?
    
    @IBOutlet var userNameLabel: UITextField!
    @IBOutlet var userImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let userName = delegate?.userName {
            
            userNameLabel.text = userName
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

    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if (self.isMovingFromParentViewController) {
            if let name = userNameLabel.text {
                
                delegate?.onDismissEditUser(newName: name)
            }
        }
    }
    
}
