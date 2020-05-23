//
//  MovieListViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/18/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

protocol MovieListNavDelegate: NavDelegate {
    func onViewMovieDetails(movie: Movie)
    func onNextStepMovieList()
}

protocol MovieListDataDelegate: DataDelegate {
    var movieResults: [PrioritizableResult] { get }
    var maxPickCount: Int { get }
    
    func applyMovieSelectionsForCurrentWatcher(moviePicks: [PrioritizableResult])
    func goToNextSelectionStep()
}

class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var results: [PrioritizableResult] {
        return dataDelegate?.movieResults ?? []
    }
    
    var maxPickCount: Int {
        return dataDelegate?.maxPickCount ?? 3
    }
    
    var navDelegate: MovieListNavDelegate?
    var dataDelegate: MovieListDataDelegate?
   
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var instructionsLabel: UILabel!

    @IBAction func onNextStep() {
        
        // capture the selected results
        if let selections = tableView.indexPathsForSelectedRows {
            
            var moviePicks: [PrioritizableResult] = []
            
            for indexPath in selections {
                moviePicks.append(results[indexPath.row])
            }
            
            dataDelegate?.applyMovieSelectionsForCurrentWatcher(moviePicks: moviePicks)
        }
        
        dataDelegate?.goToNextSelectionStep()
        navDelegate?.onNextStepMovieList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        buttonView.isHidden = true
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        tableView.reloadData()
    }
        
    func updateInstructionLabel() {
        if let selections = tableView.indexPathsForSelectedRows {
            
            switch selections.count {
            case 0:
                instructionsLabel.text = "Please pick your preferred \(maxPickCount) movies..."
                buttonView.isHidden = true
            case 1..<maxPickCount:
                instructionsLabel.text = "...please pick \(maxPickCount - selections.count) more movies..."
                buttonView.isHidden = true
            case maxPickCount:
                instructionsLabel.text = "...now tap the 'Next Step' button."
                buttonView.isHidden = false
            default:
                break
            }
        }
    }

    
    
    //////////////////////////////////////////////
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        // clear out any residual stuff from cell's former life
        cell.titleLabel?.text = ""
        
        // make sure the index path is within range
        if results.indices.contains(indexPath.row) {
            
            // get the appropriate result
            let result = results[indexPath.row]
            let movie = result.movie
            
            // set up the cell with the result information
            cell.photoURL = movie.posterPath
            cell.titleLabel.text = movie.title
            cell.yearLabel.text = "(\(movie.releaseDate.year))"
            cell.ratingLabel.text = "Rating: \(movie.voteAverage)"
            cell.cellFrame.backgroundColor = result.priority.color
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {

        navDelegate?.onViewMovieDetails(movie: results[indexPath.row].movie)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows,
            let firstIndexPath = selectedIndexPaths.first {
            
            if selectedIndexPaths.count > maxPickCount {
                tableView.deselectRow(at: firstIndexPath, animated: true)
            }
        }
        
        // play sound
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
        
        updateInstructionLabel()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        // play sound
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
        
        updateInstructionLabel()
    }
}
