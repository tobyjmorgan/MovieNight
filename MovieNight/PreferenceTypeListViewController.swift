//
//  PreferenceTypeListViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class PreferenceTypeListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var userNameDelegate: UserNameDelegate?
    var userSelectionDelegate: UserSelectionDelegate?
    var currentEndpoint: TMBDEndpoint? = nil
    
    let client = TMBDAPIClient()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var summaryLabel: UILabel!
    
    @IBAction func onNext() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        buttonView.layer.cornerRadius = 10.0
        buttonView.layer.borderWidth = 2.0
        buttonView.layer.borderColor = UIColor.white.cgColor

        updateSummary()
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
        
        if let userSelection = userSelectionDelegate?.userSelection,
            userSelection.description != "" {
            
            // enable button
            buttonView.isHidden = false
            
        } else {
            
            // enable button
            buttonView.isHidden = true
        }
    }

    func updateSummary() {
        
        if let userSelection = userSelectionDelegate?.userSelection {
            
            summaryLabel.text = userSelection.description
        }
        
        // whenever the summary might change the button might change too
        toggleNextButton()
    }
    
    
    
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
        
        if let preference = PreferenceType(rawValue: indexPath.row) {
            switch preference {
            case .genres:
                performSegue(withIdentifier: "Genres", sender: nil)
            case .eras:
                performSegue(withIdentifier: "Eras", sender: nil)
            case .people:
                performSegue(withIdentifier: "People", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GenresTableViewController {
            
            vc.navigationItem.title = "Genres"
            vc.userSelectionDelegate = userSelectionDelegate
        }
        
        if let vc = segue.destination as? ErasTableViewController {
            
            vc.navigationItem.title = "Eras"
            vc.userSelectionDelegate = userSelectionDelegate
        }

        if let vc = segue.destination as? PeopleCollectionViewController {
            
            vc.navigationItem.title = "People"
            vc.userSelectionDelegate = userSelectionDelegate
        }
    }
}
