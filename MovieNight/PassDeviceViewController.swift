//
//  PassDeviceViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/11/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class PassDeviceViewController: UIViewController {

    var userNameDelegate: UserNameDelegate?
    var userSelectionDelegate: UserSelectionDelegate?
    
    @IBOutlet var passDeviceLabel: UILabel!
    @IBOutlet var buttonView: UIView!
    
    @IBAction func onNextStep() {
        performSegue(withIdentifier: "PickPreferences", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonView.layer.cornerRadius = 10.0
        buttonView.layer.borderWidth = 2.0
        buttonView.layer.borderColor = UIColor.white.cgColor
        
        if let name = userNameDelegate?.currentUserName {
            
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
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PreferenceTypeListViewController {
            
            if let name = userNameDelegate?.currentUserName {
                
                vc.navigationItem.title = name
            }

            vc.userSelectionDelegate = userSelectionDelegate
            vc.userNameDelegate = userNameDelegate
        }
    }
}
