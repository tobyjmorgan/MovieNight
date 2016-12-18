//
//  MovieDetailViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/17/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    var movie: Movie?
    
    @IBOutlet var photo: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var releaseLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var popularityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let movie = movie {
            UIImage.getImageAsynchronously(urlString: movie.posterPath) {[weak self] image in
                self?.photo.image = image
            }
            titleLabel.text = movie.title
            overviewLabel.text = movie.overview
            releaseLabel.text = "\(movie.releaseDate.year)"
            ratingLabel.text = "\(movie.voteAverage)"
            popularityLabel.text = "\(movie.popularity)"
        }
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
