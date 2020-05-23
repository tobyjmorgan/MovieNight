//
//  PreferenceTypeListViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

protocol PreferenceTypeListNavDelegate: NavDelegate {
    func onNextStepPreferenceTypeList()
    func onShowPreferenceTypeDetails()
}

protocol PreferenceTypeListDataDelegate: DataDelegate {
    var currentUserHasMadeSelections: Bool { get }
    var currentWatcherSelection: WatcherSelection { get }

    func setCurrentPreferenceType(preferenceType: PreferenceType)
    func goToNextSelectionStep()
}

class PreferenceTypeListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var navDelegate: PreferenceTypeListNavDelegate?
    weak var dataDelegate: PreferenceTypeListDataDelegate?
        
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var summaryLabel: UILabel!
    
    @IBAction func onNext() {
        
        if let dataDelegate = dataDelegate,
            let navDelegate = navDelegate {
            
            dataDelegate.goToNextSelectionStep()
            navDelegate.onNextStepPreferenceTypeList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateSummary()
    }
    
    func toggleNextButton() {
        
        if (dataDelegate?.currentUserHasMadeSelections ?? false) {
            
            // enable button
            buttonView.isHidden = false
            
        } else {
            
            // enable button
            buttonView.isHidden = true
        }
    }

    func updateSummary() {
        
        summaryLabel.text = dataDelegate?.currentWatcherSelection.description ?? ""
        
        // whenever the summary might change the button might change too
        toggleNextButton()
    }
    
    

    
    /////////////////////////////////////////////
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return PreferenceType.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceCell", for: indexPath) as! PreferenceCell
        
        if let preference = PreferenceType(rawValue: indexPath.row) {
            
            cell.titleLabel?.text = preference.description
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let preferenceType = PreferenceType(rawValue: indexPath.row) {
            
            // play sound
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
            
            dataDelegate?.setCurrentPreferenceType(preferenceType: preferenceType)
            navDelegate?.onShowPreferenceTypeDetails()
        }
    }    
}
