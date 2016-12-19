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
        
        if let delegate = userSelectionDelegate {
            
            switch delegate.selectionMode {

            case .preferencesSelection:
                performSegue(withIdentifier: "PickPreferences", sender: nil)
            case .movieSelection:
                performSegue(withIdentifier: "MovieResults", sender: nil)
            default:
                // should never get here
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonView.myWhiteBorder()
        
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
        
        if let vc = segue.destination as? MovieListViewController {
            
            if let name = userNameDelegate?.currentUserName {
                
                vc.navigationItem.title = name
            }
            
            vc.userSelectionDelegate = userSelectionDelegate
            vc.userNameDelegate = userNameDelegate
        }
    }
    
    // Thanks to shreena shah for this neat way of hooking in to the back button
    // http://stackoverflow.com/a/32667598
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if parent == nil {
            // switch back to previous user in the model
            userSelectionDelegate?.goBackToPreviouStep()
        }
    }
}
