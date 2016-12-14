//
//  GenresTableViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class GenresTableViewController: UITableViewController {

    let client = TMBDAPIClient()
    let maxCount = 3
    
    @IBOutlet var pickCountLabel: UILabel!

    var userSelectionDelegate: UserSelectionDelegate?
    
    var genres: [Genre] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let endpoint = TMBDEndpoint.genres
        client.fetch(endpoint: endpoint, parse: endpoint.parser) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let payload):
                if let concreteResults = payload as? [Genre] {
                    self.genres = concreteResults
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var refreshGenres: [Genre] = []
        
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            
            for indexPath in selectedIndexPaths {
                
                if genres.indices.contains(indexPath.row) {
                    
                    refreshGenres.append(genres[indexPath.row])
                }
            }
        }

        userSelectionDelegate?.userSelection.selectedGenres = refreshGenres
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

    
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath)
        
        // clear out any residual stuff from cell's former life
        cell.textLabel?.text = ""
        cell.tag = 0
        cell.isSelected = false
        markCellAsUnselected(cell: cell)
        
        if genres.indices.contains(indexPath.row) {
            
            let genre = genres[indexPath.row]
            cell.textLabel?.text = genre.name
            cell.tag = genre.id
        
            if let selectedGenres = userSelectionDelegate?.userSelection.selectedGenres {
                
                if selectedGenres.contains(where: { $0.id == genre.id }) {

                    cell.isSelected = true
                    markCellAsSelected(cell: cell)
                }
            }
        }
        
        updatePickCountLabel()
        
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
