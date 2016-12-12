//
//  PassDeviceViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/11/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class PassDeviceViewController: UIViewController {

    var delegate: PassDeviceDelegate?
    
    @IBOutlet var passDeviceLabel: UILabel!
    @IBOutlet var buttonView: UIView!
    
    @IBAction func onNextStep() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonView.layer.cornerRadius = 10.0
        buttonView.layer.borderWidth = 2.0
        buttonView.layer.borderColor = UIColor.white.cgColor
        
        guard let users = delegate?.wizardUsers,
            let index = delegate?.wizardUserIndex,
            users.indices.contains(index) else {
            
            buttonView.isHidden = true
            return
        }
        
        let user = users[index]
        
        passDeviceLabel.text = "Pass device to\n\(user)"
        buttonView.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
