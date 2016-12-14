//
//  GenreListViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class GenreListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let client = TMBDAPIClient()
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pickCountLabel: UILabel!

    var userNameDelegate: UserNameDelegate?
    var userSelectionDelegate: UserSelectionDelegate?
    
    var genres: [Genre] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        if let name = userNameDelegate?.currentUserName {
            userNameLabel.text = name
        }
        
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

        pickCountLabel.text = "You have picked\n\(count)/3"
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return genres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath)
        
        cell.textLabel?.text = ""
        cell.tag = 0
        cell.isSelected = false
        
        tableView.deselectRow(at: indexPath, animated: true)
        markCellAsUnselected(cell: cell)
        
        if genres.indices.contains(indexPath.row) {
            
            let genre = genres[indexPath.row]
            cell.textLabel?.text = genre.name
            cell.tag = genre.id
        
            if let selectedGenres = userSelectionDelegate?.userSelection.selectedGenres {
                
                if selectedGenres.contains(where: { $0.id == genre.id }) {
                    
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    markCellAsSelected(cell: cell)
                }
            }
        }
        
        updatePickCountLabel()
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            markCellAsSelected(cell: cell)
            
            if let selectedIndexPaths = tableView.indexPathsForSelectedRows,
                let firstIndexPath = selectedIndexPaths.first,
                let oldCell = tableView.cellForRow(at: firstIndexPath) {
                
                if selectedIndexPaths.count > 3 {
                    tableView.deselectRow(at: firstIndexPath, animated: true)
                    markCellAsUnselected(cell: oldCell)
                }
            }
        }
        
        updatePickCountLabel()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            markCellAsUnselected(cell: cell)
        }
        
        updatePickCountLabel()
    }

}
