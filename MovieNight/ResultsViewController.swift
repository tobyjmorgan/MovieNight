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

protocol ResultsNavDelegate: NavDelegate {
    func onStartOver()
}

protocol ResultsDataDelegate: DataDelegate {
    var watcherCount: Int { get }
    var allSelectedMovies: [Movie] { get }
}

class ResultsViewController: UIViewController {

    weak var navDelegate: ResultsNavDelegate?
    weak var dataDelegate: ResultsDataDelegate?
    
    var allSelectedMovies: [Movie] {
        return dataDelegate?.allSelectedMovies ?? []
    }
    
    var feedbackLabelStrings: [String] = []
    
    @IBOutlet var feedbackLabel: UILabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var buttonView: UIView!
    
    @IBAction func onStartOver() {
        navDelegate?.onStartOver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        guard let delegate = dataDelegate, allSelectedMovies.count > 0 else {
            badOutcome()
            return
        }

        // algorithm to find the duplicates i.e. movies more than one user picked
        var mutualMovies: [Movie] = []
        
        if delegate.watcherCount == 1 {
            
            let movie = allSelectedMovies[GKRandomSource.sharedRandom().nextInt(upperBound: allSelectedMovies.count)]
            displayResults(movie: movie, messages: ["Here goes...", "Picking a movie for you..."])
            
        } else {
            
                // walk one by one through the array
                for i in 0..<allSelectedMovies.count {
                    
                    let movieA = allSelectedMovies[i]
                    
                    // walk one by one through the array, but starting on the next element
                    // only look for matches if we haven't already found this to be a duplicate
                    if !mutualMovies.contains(movieA) {
                        
                        for j in i+1..<allSelectedMovies.count {
                            
                            let movieB = allSelectedMovies[j]
                            
                            if movieA == movieB {
                                // its a new duplicate, so add it to the array and move on to the next outer element
                                mutualMovies.append(movieA)
                                break
                            }
                        }
                    }
                }
            
                if mutualMovies.count == 0 {
                    
                    // no common ground, pick one at random
                    let movie = allSelectedMovies[GKRandomSource.sharedRandom().nextInt(upperBound: allSelectedMovies.count)]
                    displayResults(movie: movie, messages: ["No common ground...", "Picking a random movie from your selections..."])
                    
                } else if mutualMovies.count == 1 {
                    
                    // we have one common movie - yay perfect outcome
                    displayResults(movie: mutualMovies[0], messages: ["A match!"])
                    
                } else {
                    
                    // we have multiple matches, make a best guess pick of these
                    let movie = mutualMovies[GKRandomSource.sharedRandom().nextInt(upperBound: mutualMovies.count)]
                    displayResults(movie: movie, messages: ["Multiple matches...", "Picking most likely movie for you..."])
                }
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
    
    @objc func displayNextMessage() {
        
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
