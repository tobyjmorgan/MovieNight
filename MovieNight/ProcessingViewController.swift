//
//  ProcessingViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/18/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class ProcessingViewController: UIViewController, CAAnimationDelegate {

    @IBOutlet var eggTimerView: UIView!
    @IBOutlet var bigWheel: UIView!
    @IBOutlet var mediumWheel: UIView!
    @IBOutlet var littleWheel: UIView!
    @IBOutlet var tinyWheel: UIView!
    @IBOutlet var processingLabel: UILabel!
    @IBOutlet var errorView: UIView!

    var userNameDelegate: UserNameDelegate?
    var userSelectionDelegate: UserSelectionDelegate?

    let client = TMBDAPIClient()
    var sentRequests: Int = 0
    var returnedRequests: Int = 0
    var doneSendingRequests: Bool = false

    let spinDuration = 3.0
    let rotation = CGFloat(6.0 * M_PI_2)
    var animationsOn: Bool = true {
        didSet {
            if !animationsOn {
                
                stopSpinAnimation()
            }
        }
    }
    
    // get at least one decent spin animation in before moving on
    var doneWithFirstSpin: Bool = false {
        didSet {
            checkReturnCount()
        }
    }

    var results: [PrioritizableResult] = [] {
        didSet {
            
            checkReturnCount()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        errorView.layer.cornerRadius = 150
        
        bigWheel.layer.cornerRadius = 150
        mediumWheel.layer.cornerRadius = 115
        littleWheel.layer.cornerRadius = 80
        tinyWheel.layer.cornerRadius = 45
        
        startSpinAnimation()
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

    
    
    ////////////////////////////////////////////////////
    // MARK: pretty animations stuff
    
    func startSpinAnimation() {
        
        // spinning wheels animation
        bigWheel.rotationAnimation(rotation: rotation, duration: spinDuration, completionDelegate: self)
        mediumWheel.rotationAnimation(rotation: -rotation, duration: spinDuration)
        littleWheel.rotationAnimation(rotation: rotation, duration: spinDuration)
        tinyWheel.rotationAnimation(rotation: -rotation, duration: spinDuration)
    }
    
    func stopSpinAnimation() {
        bigWheel.layer.removeAllAnimations()
        mediumWheel.layer.removeAllAnimations()
        littleWheel.layer.removeAllAnimations()
        tinyWheel.layer.removeAllAnimations()
    }
    
    func fadeLabelIn() {
        
        if animationsOn {
            
            UIView.animate(withDuration: 0.5, animations: { self.processingLabel.alpha = 1.0 }) {[weak self] bool in
                self?.fadeLabelOut()
            }
        }
    }
    
    func fadeLabelOut() {
        
        if animationsOn {
            
            UIView.animate(withDuration: 0.5, animations: { self.processingLabel.alpha = 0.0 }) {[weak self] bool in
                self?.fadeLabelIn()
            }
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !doneWithFirstSpin {
            doneWithFirstSpin = true
        }
        
        if animationsOn {
            startSpinAnimation()
        }
    }
    
    
    
    
    ////////////////////////////////////////////////////
    // MARK: API processing
    
    func processSelections() {
        
        if let delegate = userSelectionDelegate {
            
            for userSelection in delegate.allSelections {
                
                let eras = userSelection.selectedEras
                let genreIds = userSelection.selectedGenres.map{ $0.id }
                let personIds = userSelection.selectedPeople.map{ $0.id }
                
                if eras.count > 0 {
                    
                    // process cireteria in the context of one era at a time
                    for era in userSelection.selectedEras {
                        
                        processForEra(era: era, genreIds: genreIds, personIds: personIds)
                    }
                    
                } else {
                    
                    // no eras set - so just process with nil era
                    processForEra(era: nil, genreIds: genreIds, personIds: personIds)
                    
                }
                
            }
        }
        
        doneSendingRequests = true
    }
    
    // this method encapsualtes the basic algorithm
    //   - send multiple requests
    //   - prioritize results that match ALL criteria (for a given era)
    //   - then make requests that hit on components of the overall crieteria
    func processForEra(era: MovieEra?, genreIds: [Int], personIds: [Int]) {
        
        if genreIds.count > 0 && personIds.count > 0 {
            
            // the perfect match request
            process(type: DiscoverType.moviesByGenresActors(era, genreIds, personIds), priority: .matchOnAllCriteria)
        }
        
        // the all people request
        if personIds.count > 1 {
            process(type: DiscoverType.moviesByActors(era, personIds), priority: .matchOnAllPeople)
        }
        
        // the individual people requests
        for personId in personIds {
            process(type: DiscoverType.moviesByActors(era, [personId]), priority: .matchOnOnePerson)
        }
        
        // the all genres request
        if genreIds.count > 1 {
            process(type: DiscoverType.moviesByGenres(era, genreIds), priority: .matchOnAllGenres)
        }
        
        // the individual genres requests
        for genreId in genreIds {
            process(type: DiscoverType.moviesByGenres(era, [genreId]), priority: .matchOnOneGenre)
        }
        
        // the individual era request
        if let era = era {
            process(type: DiscoverType.moviesByEra(era), priority: .matchOnOneEra)
        }
    }
    
    // utility method that sends the fetch request and handles the results
    func process(type: DiscoverType, priority: ResultPriority) {
        
        let endpoint = TMBDEndpoint.discover(type)
        client.fetch(endpoint: endpoint, parse: endpoint.parser)  {[weak self] result in
            
            self?.handleResult(for: self, priority: priority, result: result)
        }
        
        // increment the number of requests that were sent
        sentRequests += 1
    }
    
    // handle results of any incoming results
    func handleResult(for controller: ProcessingViewController?, priority: ResultPriority, result: APIResult<[JSONInitable]>) {
        
        switch result {
        case .success(let payload):

            // increment the number of returned requests
            returnedRequests += 1
            
            if let newMovies = payload as? [Movie],
                let controller = controller {
                
                // extract the movies out of the current results (strip out the priority part)
                let originalResults = controller.results
                let originalMovies = originalResults.map { $0.movie }
                
                // filter out any duplicates movies from the incoming results
                let uniqueNewMovies = newMovies.filter { !originalMovies.contains($0) }
                
                // turn the incoming de-duped movies in to prioritized results
                let newResults = uniqueNewMovies.map { PrioritizableResult(priority: priority, resultObject: $0) }
                
                // create new results list that concatenates current results and new results
                let allResults = originalResults + newResults
                
                var readyResults: [PrioritizableResult] = []

                // grouped and sorted
                for priority in ResultPriority.allValues {
                    let priorityGroup = allResults.filter { $0.priority == priority }
                    let sortedPriorityGroup = priorityGroup.sorted { $0.movie.voteAverage > $1.movie.voteAverage }
                    readyResults.append(contentsOf: sortedPriorityGroup)
                }
                
                // assign this as our new results list
                controller.results = readyResults
            }
            
        case .failure(let error):
            animationsOn = false
            if errorView.isHidden {
                handleError(error: error)
            }
        }
    }
    
    // handle errors by displaying an appropriate message
    func handleError(error: Error) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayAlertSound.rawValue), object: nil)
        
        var message: String?
        
        if let netError = error as? APIClientError {
            switch netError {
            case .missingHTTPResponse:
                message = "Missing HTTP Response."
            case .unableToSerializeDataToJSON:
                message = "Unable to serialize returned data to JSON format."
            case .unableToParseJSON(let json):
                message = "Unable to parse JSON data: returned JSON data printed to console for inspection."
                print(json)
            case .unexpectedHTTPResponseStatusCode(let code):
                message = "Unexpected HTTP response: \(code)"
            case .noDataReturned:
                message = "No data returned by HTTP request."
            case .unknownError:
                message = "Dang! There was some kind of unknown error"
            }
        }
        
        if let message = message {
            
            // needed to get model back in correct state
            userSelectionDelegate?.goBackToPreviouStep()
            
            // display error style elements
            processingLabel.text = "error"
            errorView.isHidden = false
            
            // alert the user
            let alert = UIAlertController(title: "Ouch!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func checkReturnCount() {
        if doneSendingRequests && doneWithFirstSpin {
            
            if returnedRequests == sentRequests {
                
                // segue to view the results
                performSegue(withIdentifier: "PassDevice", sender: self)
            }
        }
    }
    

    
    
    ////////////////////////////////////////////////////
    // MARK: segue processing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? PassDeviceViewController {
            
            vc.userNameDelegate = userNameDelegate
            vc.userSelectionDelegate = userSelectionDelegate

            // capture the results in the delegate
            userSelectionDelegate?.movieResults = results
        }
    }


}
