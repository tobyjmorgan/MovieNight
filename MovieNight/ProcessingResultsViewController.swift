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
    
    // rotation transform animation on a UIView
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

class ProcessingResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let client = TMBDAPIClient()
    
    var results: [PrioritizableResult] = [] {
        didSet {
            
            // refresh the table
            tableView.reloadData()
        }
    }
    
    let waitDuration = 5.0
    var lastSelectedResult: PrioritizableResult?
    
    @IBOutlet var eggTimerView: UIView!
    @IBOutlet var bigWheel: UIView!
    @IBOutlet var mediumWheel: UIView!
    @IBOutlet var littleWheel: UIView!
    @IBOutlet var tinyWheel: UIView!
    @IBOutlet var processingLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var userSelectionsStackView: UIStackView!
    
    @IBAction func onStartOver() {
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    var userSelectionDelegate: UserSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eggTimerView.isHidden = false
        view.bringSubview(toFront: eggTimerView)
        
        createSelectionDetailLabels()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        buttonView.myWhiteBorder()
        
        bigWheel.layer.cornerRadius = 150
        mediumWheel.layer.cornerRadius = 115
        littleWheel.layer.cornerRadius = 80
        tinyWheel.layer.cornerRadius = 45
        
        let rotation = CGFloat(12.0 * M_PI_2)
        
        // spinning wheels animation
        bigWheel.rotationAnimation(rotation: rotation, duration: waitDuration)
        mediumWheel.rotationAnimation(rotation: -rotation, duration: waitDuration)
        littleWheel.rotationAnimation(rotation: rotation, duration: waitDuration)
        tinyWheel.rotationAnimation(rotation: -rotation, duration: waitDuration)
        
        // just waiting a fixed five seconds to get some results back before displaying the results
        // given that there are multiple requests and all are coming in at different times I didn't want to drive the
        // end of the animation by any one of these requests' results
        // I could have put in a counter system so that when all requests had come in the animation was hidden
        Timer.scheduledTimer(timeInterval: waitDuration, target: self, selector: #selector(ProcessingResultsViewController.waitIsOver), userInfo: nil, repeats: false)
        
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
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // Thanks to shreena shah for this neat way of hooking in to the back button
    // http://stackoverflow.com/a/32667598
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if parent == nil {
            // switch back to previous user in the model
            userSelectionDelegate?.goingBack()
        }
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
    
    func waitIsOver() {
        UIView.animate(withDuration: 0.5, animations: {self.eggTimerView.alpha = 0.0}) {bool in
            self.eggTimerView.isHidden = true
        }
    }
    
    
    // method to show what criteria was used in the processing of results
    // broken out by user
    func createSelectionDetailLabels() {
        
        let defaults = UserDefaults.standard

        if let users = defaults.value(forKey: UserDefaultsKey.usersArray.rawValue) as? [String],
            let delegate = userSelectionDelegate {
            
            for i in 0..<users.count {
                
                let user = users[i]
                let selection = delegate.allSelections[i]

                let label = UILabel()
                label.text = "\(user):\n" + String.concatenateWithCommas(arrayOfItems: [selection.selectedErasDescription, selection.selectedGenresDescription, selection.selectedPeopleDescription])
                label.font = UIFont(name: "Helvetica", size: 12)
                label.textColor = UIColor.white
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                
                userSelectionsStackView.addArrangedSubview(label)
            }
        }
    }
    
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
    }
    
    // this method encapsualtes the basic algorithm
    //   - send multiple requests
    //   - prioritize results that match ALL criteria (for a given era)
    //   - then make requests that hit on components of the overall crieteria
    func processForEra(era: MovieEra?, genreIds: [Int], personIds: [Int]) {
        
        // the perfect match request
        process(type: DiscoverType.moviesByGenresActors(era, genreIds, personIds), priority: .matchOnAllCriteria)
        
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
    }
    
    // utility method that sends the fetch request and handles the results
    func process(type: DiscoverType, priority: ResultPriority) {
        
        let endpoint = TMBDEndpoint.discover(type)
        client.fetch(endpoint: endpoint, parse: endpoint.parser)  {[weak self] result in
            
            self?.handleResult(for: self, priority: priority, result: result)
        }
    }
    
    // handle results of any incoming results
    func handleResult(for controller: ProcessingResultsViewController?, priority: ResultPriority, result: APIResult<[JSONInitable]>) {
        
        switch result {
        case .success(let payload):
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
                
                // sort by priority (just in case results come in out of order)
                let sortedResults = allResults.sorted { $0.priority.rawValue < $1.priority.rawValue }
                
                // assign this as our new results list
                controller.results = sortedResults
            }
            
        case .failure(let error):
            handleError(error: error)
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
                message = "Dang! There was somekind of unknown error"
            }
        }
        
        if let message = message {
            
            let alert = UIAlertController(title: "Ouch!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // go to the movie detail screen
        lastSelectedResult = results[indexPath.row]
        performSegue(withIdentifier: "MovieDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? MovieDetailViewController {
            
            // let the movie detail screen know what to show
            vc.movie = lastSelectedResult?.movie
        }
    }
}
