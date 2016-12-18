//
//  SetUpViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/11/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class SetUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditUserDelegate {

    let sounds = SoundManager()
    var model: Model? = nil
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

        // try to create a model (will use the standard user defaults in this process)
        // failable initializer, so don't proceed if it fails
        if let newModel = Model() {
            
            model = newModel
            performSegue(withIdentifier: "PassDevice", sender: nil)
        }
    }
    
    @IBAction func onInsert() {
        
        insertNewObject()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        buttonView.myWhiteBorder()
        
        if !defaults.bool(forKey: UserDefaultsKey.everBeenRunBefore.rawValue) {
            
            setUsers(users: ["Watcher 1", "Watcher 2"])
            defaults.set(true, forKey: UserDefaultsKey.everBeenRunBefore.rawValue)
            defaults.synchronize()
        }

        // TODO: just hardcoding in UserDefaults - in a real app, would query API Configuration first
        defaults.setValue("https://image.tmdb.org/t/p/w185", forKey: UserDefaultsKey.photoRootPath.rawValue)
        defaults.synchronize()
        
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
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        defaults.synchronize()
        
        toggleBeginButton()
    }
    
    func toggleBeginButton() {
        
//        if let users = users,
//            users.count > 1 {
            
            // enable button
            buttonView.isHidden = false
            
//        } else {
//
//            // disable button
//            buttonView.isHidden = true
//        }
        
    }
    
    
    
    
    /////////////////////////////////////////////
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
    
    
    
    
    /////////////////////////////////////////////
    // MARK: Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditUserViewController {
            
            vc.delegate = self
            
        } else if let vc = segue.destination as? PassDeviceViewController {
            
            vc.userNameDelegate = model
            vc.userSelectionDelegate = model
        }
    }
    
    

    
    /////////////////////////////////////////////
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
    
    func onPassDeviceDismiss() {
        
        // do nothing yet
    }
}
