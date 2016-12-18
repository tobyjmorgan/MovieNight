//
//  ListViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/15/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var maxPickCount: Int = 3
    var instruction: String = "Please make your selections..."
    var dismissCompletion: (([Listable]) -> ())? = nil
    
    var initiallyPicked: [Listable] = []
    
    // generic table view, so we don't care what underlying type is passed, as long
    // as it conforms to Listable
    var list: [Listable] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var pickCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        instructionLabel.text = instruction
        updatePickCountLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveSelections()
    }
    
    func updatePickCountLabel() {
        
        var count = 0
        
        if let selectedRows = tableView.indexPathsForSelectedRows {
            count = selectedRows.count
        }
        
        pickCountLabel.text = "You have picked \(count)/\(maxPickCount)"
    }

    func saveSelections() {
        
        var returnList: [Listable] = []
        
        if let selectedRows = tableView.indexPathsForSelectedRows {
            
            returnList = selectedRows.map { list[$0.row] }
        }
        
        dismissCompletion?(returnList)
    }

    

    
    ///////////////////////////////////////////////
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListCell
        
        // clear out any residual stuff from cell's former life
        cell.textLabel?.text = ""
        
        // check for out of bounds
        if list.indices.contains(indexPath.row) {
            
            // fetch the corresponding list item for the row
            let item = list[indexPath.row]
            
            // set the title
            cell.titleLabel?.text = item.titleForItem
            
            if let index = initiallyPicked.index(where: { $0.uniqueID == item.uniqueID}) {
                
                // remove it from the initially picked list (because we will probably change our selections)
                initiallyPicked.remove(at: index)
                
                // mark cell as selected
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                updatePickCountLabel()
            }
        
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows,
            let firstIndexPath = selectedIndexPaths.first {
            
            if selectedIndexPaths.count > maxPickCount {
                tableView.deselectRow(at: firstIndexPath, animated: true)
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
        updatePickCountLabel()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updatePickCountLabel()
    }
}
