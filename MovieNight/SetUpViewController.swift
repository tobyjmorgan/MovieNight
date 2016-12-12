//
//  SetUpViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/11/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class SetUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditUserDelegate, PassDeviceDelegate {

    let defaults = UserDefaults.standard
    var currentUserIndex: Int?

    var users: [String]? {
        
        guard let users = defaults.array(forKey: UserDefaultsKey.usersArray.rawValue) as? [String] else {
            return nil
        }
        
        return users
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonView: UIView!
    
    @IBAction func onBegin() {
        performSegue(withIdentifier: "PassDevice", sender: nil)
    }
    
    @IBAction func onInsert() {
        
        insertNewObject()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        buttonView.layer.cornerRadius = 10.0
        buttonView.layer.borderWidth = 2.0
        buttonView.layer.borderColor = UIColor.white.cgColor
        
        if !defaults.bool(forKey: UserDefaultsKey.everBeenRunBefore.rawValue) {
            
            setUsers(users: ["Watcher 1", "Watcher 2"])
            defaults.set(true, forKey: UserDefaultsKey.everBeenRunBefore.rawValue)
        }
        
        toggleBeginButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // toggling the appearance of the navigation bar
    // Thanks to Michael Garito on StackOverflow for this
    // http://stackoverflow.com/questions/29209453/how-to-hide-a-navigation-bar-from-first-viewcontroller-in-swift
    override func viewWillAppear(_ animated: Bool) {
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func insertNewObject() {
        
        if let users = users {
            
            let newUsers = users + ["Watcher \(users.count+1)"]
            setUsers(users: newUsers)
        }
        
        let indexPath = IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func setUsers(users: [String]) {
        
        defaults.set(users, forKey: UserDefaultsKey.usersArray.rawValue)
        
        toggleBeginButton()
    }
    
    func toggleBeginButton() {
        
        if let users = users,
            users.count > 1 {
            
            // enable button
            buttonView.isHidden = false
            
        } else {
            
            // disable button
            buttonView.isHidden = true
        }
        
    }
    
    
    
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let users = users {
            return users.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SetUpCell", for: indexPath) as! SetUpTableViewCell

        if let users = users,
            users.indices.contains(indexPath.row) {
            
            cell.title.text = users[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentUserIndex = indexPath.row
        performSegue(withIdentifier: "EditUser", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if var users = users,
                users.indices.contains(indexPath.row) {
                
                users.remove(at: indexPath.row)
                
                setUsers(users: users)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    
    
    // MARK: Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditUserViewController {
            
            vc.delegate = self
            
        } else if let vc = segue.destination as? PassDeviceViewController {
            
            vc.delegate = self
        }
    }
    
    

    
    // MARK: EditUserDelegate
    
    var userName: String {
        
        guard let users = users,
            let lastTouchedUserIndex = currentUserIndex,
            users.indices.contains(lastTouchedUserIndex) else {
            return ""
        }
        
        return users[lastTouchedUserIndex]
    }
    
    func onDismissEditUser(newName: String) {
        
        if var users = users,
            let lastTouchedUserIndex = currentUserIndex,
            users.indices.contains(lastTouchedUserIndex) {
            
            users[lastTouchedUserIndex] = newName
            setUsers(users: users)
        }
        
        tableView.reloadData()
    }
    
    
    
    
    // MARK: PassDeviceDelegate
    
    var wizardUserIndex: Int {
        
        // kick off the movie picking process with the first user in the list
        return 0
    }
    
    var wizardUsers: [String] {

        // we can bang here because the next step button only shows up if we
        // have two or more users to work with
        return users!
    }
    
    func onPassDeviceDismiss() {
        // do nothing as yet
    }
}
