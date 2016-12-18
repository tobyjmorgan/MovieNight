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
        
        if let delegate = userSelectionDelegate {
            
            // play sound
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
            
            switch delegate.onMoveOnToNextUser() {
            
            case .readyForNextUser:
                // go back to the "Pass Device" screen
                performSegue(withIdentifier: "NextUser", sender: self)

            case .thatWasTheLastOne:
                // we're done picking, so
                performSegue(withIdentifier: "ProcessResults", sender: self)
            
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        buttonView.myWhiteBorder()

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
        
        if let preference = PreferenceType(rawValue: indexPath.row) {
            
            // play sound
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
            
            // segue to correct screen
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
    
    
    
    
    /////////////////////////////////////////////
    // MARK: Segues

    // this view controller segues to a lot of different places!!!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? ListViewController {
            
            // ListViewController is a generic, multipurpose table view controller
            // so here we set it up to display the information we want
            // based on what context we are calling it
            
            if segue.identifier == "Genres" {
                
                // genres are driven by the API, so we send a fetch request
                let endpoint = TMBDEndpoint.genres
                client.fetch(endpoint: endpoint, parse: endpoint.parser) { result in
                    
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let payload):
                        if let concreteResults = payload as? [Genre] {
                            vc.list = concreteResults
                        }
                    }
                }
                
                vc.navigationItem.title = "Genres"
                vc.instruction = "Pick some genres..."
                
                if let selected = userSelectionDelegate?.userSelection.selectedGenres {
                    
                    vc.initiallyPicked = selected
                }

                vc.dismissCompletion = {[weak self] listables in
                    
                    if let genres = listables as? [Genre] {
                        
                        self?.userSelectionDelegate?.userSelection.selectedGenres = genres
                    }
                }
                
            } else if segue.identifier == "Eras" {
                
                // eras use hardcoded data, so no API request needed
                vc.list = MovieEra.allValues
                
                vc.navigationItem.title = "Movie Eras"
                vc.instruction = "Pick any movie eras you prefer..."
                
                if let selected = userSelectionDelegate?.userSelection.selectedEras {
                    
                    vc.initiallyPicked = selected
                }
                
                vc.dismissCompletion = {[weak self] listables in
                    
                    if let eras = listables as? [MovieEra] {
                        
                        self?.userSelectionDelegate?.userSelection.selectedEras = eras
                    }
                }
            }
        }
        
        // to display the photos we will use a collection view controller
        // it is also generic, although we are only using it in one context in this app
        if let vc = segue.destination as? PhotoListViewController {
            
            for page in 1...10 {
                
                let endpoint = TMBDEndpoint.popularPeople(page)
                client.fetch(endpoint: endpoint, parse: endpoint.parser) { result in
                    
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let payload):
                        if let concreteResults = payload as? [Person] {
                            
                            for person in concreteResults {
                                
                                vc.list.append(person)
                            }
                        }
                    }
                }
            }

            vc.navigationItem.title = "Stars"
            vc.instruction = "Pick your favorite stars..."
            
            if let selected = userSelectionDelegate?.userSelection.selectedPeople {
                
                vc.initiallyPicked = selected
            }
            
            vc.dismissCompletion = {[weak self] listables in
                
                if let people = listables as? [Person] {
                    
                    self?.userSelectionDelegate?.userSelection.selectedPeople = people
                }
            }
        }
        
        // pass to next player
        if let vc = segue.destination as? PassDeviceViewController {
            
            vc.userNameDelegate = userNameDelegate
            vc.userSelectionDelegate = userSelectionDelegate
        }
        
        // process the results
        if let vc = segue.destination as? ProcessingResultsViewController {
            vc.userSelectionDelegate = userSelectionDelegate
        }
    }
}
