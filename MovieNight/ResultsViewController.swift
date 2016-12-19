//
//  ResultsViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/18/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit
import GameKit
import SAMCache

class ResultsViewController: UIViewController {

    var userSelectionDelegate: UserSelectionDelegate?
    
    var feedbackLabelStrings: [String] = []
    
    @IBOutlet var feedbackLabel: UILabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var buttonView: UIView!
    
    @IBAction func onStartOver() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonView.myWhiteBorder()
        buttonView.isHidden = true
        
        feedbackLabel.isHidden = true
        photo.isHidden = true
        titleLabel.isHidden = true
        
        processResults()
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

    func processResults() {
        
        guard let delegate = userSelectionDelegate else {
            badOutcome()
            return
        }
        
        
        let allResults = delegate.allSelections.flatMap({ $0.selectedResults })
        
        guard allResults.count > 0 else {
            badOutcome()
            return
        }

        // algorithm to find the duplicates i.e. movies more than one user picked
        var duplicateMovies: [Movie] = []
        
        // walk one by one through the array
        for i in 0..<allResults.count {
            
            let movieA = allResults[i].movie
            
            // walk one by one through the array, but starting on the next element
            // only look for matches if we haven't already found this to be a duplicate
            if !duplicateMovies.contains(movieA) {
                
                for j in i+1..<allResults.count {
                    
                    let movieB = allResults[j].movie
                    
                    if movieA == movieB {
                        // its a new duplicate, so add it to the array and move on to the next outer element
                        duplicateMovies.append(movieA)
                        break
                    }
                }
            }
        }
    
        if duplicateMovies.count == 0 {
            
            // no common ground, pick one at random
            let movie = allResults[GKRandomSource.sharedRandom().nextInt(upperBound: allResults.count)].movie
            displayResults(movie: movie, messages: ["No common ground...", "Picking a random movie from your selections..."])
            
        } else if duplicateMovies.count == 1 {
            
            // we have one common movie - yay perfect outcome
            displayResults(movie: duplicateMovies[0], messages: ["A match!"])
            
        } else {
            
            // we have multiple matches, make a best guess pick of these
            let movie = duplicateMovies[GKRandomSource.sharedRandom().nextInt(upperBound: duplicateMovies.count)]
            displayResults(movie: movie, messages: ["Multiple matches...", "Picking most likely movie for you..."])
        }
    }

    func badOutcome() {
        
        feedbackLabel.text = "Bummer, no results!"
        buttonView.isHidden = false
    }

    func displayResults(movie: Movie, messages: [String]) {
        
        // set the image
        if let cachedImage = SAMCache.shared().image(forKey: movie.posterPath) {
            
            photo.image = cachedImage
            
        } else {
            
            UIImage.getImageAsynchronously(urlString: movie.posterPath) {[weak self] image in
                self?.photo.image = image
            }
        }
        
        titleLabel.text = "\(movie.title) (\(movie.releaseDate.year))"
        
        feedbackLabelStrings = messages + ["Your movie tonight will be..."]
        
        perform(#selector(ResultsViewController.displayNextMessage), with: nil, afterDelay: 2.0)
    }
    
    func displayNextMessage() {
        
        if let message = feedbackLabelStrings.first {
            
            feedbackLabelStrings.removeFirst()
            feedbackLabel.isHidden = false
            
            // play sound
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
            
            feedbackLabel.text = message
            perform(#selector(ResultsViewController.displayNextMessage), with: nil, afterDelay: 2.0)
            
        } else {
            
            // play sound
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayTadaSound.rawValue), object: nil)
            
            photo.isHidden = false
            titleLabel.isHidden = false
            
            buttonView.isHidden = false
        }
    }
}
