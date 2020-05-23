//
//  SetUpViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/11/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

protocol SetUpNavDelegate: NavDelegate {
    func onNavEditWatcher(watcherIndex: Int)
    func onNavStartSearch()
}

protocol SetUpDataDelegate: DataDelegate {
    var watchers: [Watcher] { get }
    
    func addDefaultWatcher()
    func removeWatcher(atIndex: Int)
    func goToFirstSelectionStep()
}

class SetUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var dataDelegate: SetUpDataDelegate?
    weak var navDelegate: SetUpNavDelegate?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonView: UIView!
    
    var watchers: [Watcher] {
        return dataDelegate?.watchers ?? []
    }
    
    @IBAction func onBegin() {
        
        dataDelegate?.goToFirstSelectionStep()
        navDelegate?.onNavStartSearch()
    }
    
    @IBAction func onInsert() {
        
        if let delegate = dataDelegate {
            
            delegate.addDefaultWatcher()
            
            let indexPath = IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)

            toggleBeginButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func toggleBeginButton() {
        
        if watchers.count > 0 {
            
            buttonView.isHidden = false
            
        } else {
            
            buttonView.isHidden = true
        }
    }
    
    
    
    
    /////////////////////////////////////////////
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return watchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SetUpCell", for: indexPath) as! SetUpTableViewCell

        if watchers.indices.contains(indexPath.row) {
                
            cell.title.text = watchers[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        navDelegate?.onNavEditWatcher(watcherIndex: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if watchers.indices.contains(indexPath.row) {
                    
                if let delegate = dataDelegate {
                    
                    delegate.removeWatcher(atIndex: indexPath.row)
                    
                    toggleBeginButton()
                    
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
