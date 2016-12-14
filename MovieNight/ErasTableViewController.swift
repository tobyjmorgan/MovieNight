//
//  ErasTableViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/14/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class ErasTableViewController: UITableViewController {

    let maxCount = 3

    var userSelectionDelegate: UserSelectionDelegate?

    @IBOutlet var pickCountLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        updatePickCountLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        var refreshEras: [MovieEra] = []
        
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            
            for indexPath in selectedIndexPaths {
                
                if let era = MovieEra(rawValue: indexPath.row) {
                    
                    refreshEras.append(era)
                }
            }
        }
        
        userSelectionDelegate?.userSelection.selectedEras = refreshEras
    }
    
    func updatePickCountLabel() {
        
        var count = 0
        
        if let selectedRows = tableView.indexPathsForSelectedRows {
            count = selectedRows.count
        }
        
        pickCountLabel.text = "You have picked \(count)/\(maxCount)"
    }

    func markCellAsSelected(cell: UITableViewCell) {
        
        if cell.isSelected {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
    }
    
    func markCellAsUnselected(cell: UITableViewCell) {
        
        if !cell.isSelected {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
    }

    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieEra.allValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EraCell", for: indexPath)

        // clear out any residual stuff from cell's former life
        cell.textLabel?.text = ""
        
        if let era = MovieEra(rawValue: indexPath.row) {
            
            cell.textLabel?.text = era.description
            
            if let selectedEras = userSelectionDelegate?.userSelection.selectedEras {
                
                if selectedEras.contains(where: { $0 == era }) {
                    
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    markCellAsSelected(cell: cell)
                }
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            markCellAsSelected(cell: cell)
            
            if let selectedIndexPaths = tableView.indexPathsForSelectedRows,
                let firstIndexPath = selectedIndexPaths.first,
                let oldCell = tableView.cellForRow(at: firstIndexPath) {
                
                if selectedIndexPaths.count > maxCount {
                    tableView.deselectRow(at: firstIndexPath, animated: true)
                    markCellAsUnselected(cell: oldCell)
                }
            }
        }
        
        updatePickCountLabel()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            markCellAsUnselected(cell: cell)
        }
        
        updatePickCountLabel()
    }

}
