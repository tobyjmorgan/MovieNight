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
    @IBOutlet var movieInfoView: UIView!
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
        movieInfoView.isHidden = true
        
        processResults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            // no common ground, make a best guess pick
            if let movie = delegate.movieResults.first?.movie {
                
                displayResults(movie: movie, messages: ["No common ground...", "Picking most likely movie for you..."])
                
            } else {
                
                badOutcome()
            }
            
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
        
        displayNextMessage()
    }
    
    func displayNextMessage() {
        
        if let message = feedbackLabelStrings.first {
            
            feedbackLabelStrings.removeFirst()
            
            // play sound
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
            
            feedbackLabel.text = message
            perform(#selector(ResultsViewController.displayNextMessage), with: nil, afterDelay: 1.4)
            
        } else {
            
            // play sound
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayTadaSound.rawValue), object: nil)
            
            movieInfoView.isHidden = false
            buttonView.isHidden = false
        }
    }
}
