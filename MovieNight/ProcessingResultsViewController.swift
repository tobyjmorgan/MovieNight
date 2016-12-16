//
//  ProcessingResultsViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/16/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

// adapted from code by Andrew Bancroft
// https://www.andrewcbancroft.com/2014/10/15/rotate-animation-in-swift/
extension UIView {
    
    func rotationAnimation(rotation: CGFloat, duration: CFTimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = nil) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = rotation
        rotateAnimation.duration = duration
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        if let delegate = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

class ProcessingResultsViewController: UIViewController {

    let client = TMBDAPIClient()
    
    var movies: [Movie] = [] {
        didSet {
            
        }
    }
    
    @IBOutlet var bigWheel: UIView!
    @IBOutlet var littleWheel: UIView!
    @IBOutlet var tinyWheel: UIView!
    @IBOutlet var processingLabel: UILabel!
    
    var userSelectionDelegate: UserSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        bigWheel.layer.cornerRadius = 150
        littleWheel.layer.cornerRadius = 80
        tinyWheel.layer.cornerRadius = 45
        
        let rotation = CGFloat(12.0 * M_PI_2)
        
        self.bigWheel.rotationAnimation(rotation: rotation, duration: 5.0)
        self.littleWheel.rotationAnimation(rotation: -rotation, duration: 5.0)
        self.tinyWheel.rotationAnimation(rotation: rotation, duration: 5.0)
        
        fadeLabelOut()
        
        processSelections()
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

    func fadeLabelIn() {
        UIView.animate(withDuration: 0.5, animations: { self.processingLabel.alpha = 1.0 }) {[weak self] bool in
            self?.fadeLabelOut()
        }
    }
    
    func fadeLabelOut() {
        UIView.animate(withDuration: 0.5, animations: { self.processingLabel.alpha = 0.0 }) {[weak self] bool in
            self?.fadeLabelIn()
        }
    }
    
    func processSelections() {
        if let delegate = userSelectionDelegate {
            
            for userSelection in delegate.allSelections {
                
                for genre in userSelection.selectedGenres {
                    
                    let endpoint = TMBDEndpoint.discover(DiscoverType.moviesByGenre(genre.id))
                    client.fetch(endpoint: endpoint, parse: endpoint.parser)  {[weak self] result in
                        
                        self?.handleResult(for: self, result: result)
                    }
                }
                
                for era in userSelection.select {
                    
                    let endpoint = TMBDEndpoint.discover(DiscoverType.moviesByGenre(genre.id))
                    client.fetch(endpoint: endpoint, parse: endpoint.parser)  {[weak self] result in
                        
                        self?.handleResult(for: self, result: result)
                    }
                }
            }
        }
    }
    
    func handleResult(for controller: ProcessingResultsViewController?, result: APIResult<[JSONInitable]>) {
        
        switch result {
        case .success(let payload):
            if let movies = payload as? [Movie] {
                controller?.movies.append(contentsOf: movies)
            }
        case .failure(_):
            // just ignore
            break
        }
    }

}
