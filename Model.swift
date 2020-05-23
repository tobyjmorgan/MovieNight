//
//  Model.swift
//  MovieNight
//
//  Created by redBred LLC on 12/12/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

enum SelectionMode {
    case preferencesSelection
    case movieSelection
    case done
}

public typealias Watcher = String // May change to something more complex later

// our simple model
public final class Model {

    var currentEndpoint: TMBDEndpoint? = nil
    
    let client = TMBDAPIClient()

    var currentWatcherIndex: Int = 0
    var watcherSelections: [WatcherSelection] = []
    var selectionMode: SelectionMode = .preferencesSelection
    var maxPickCount: Int = 3
    
    var movieResults: [PrioritizableResult] = []
    
    var currentPreferenceType: PreferenceType = .eras
    
    let storage = UserDefaults.standard
    
    let dispatchGroup = DispatchGroup()
    weak var processingCompletedDelegate: ProcessingCompletedDelegate?
    var results: [PrioritizableResult] = []


    init() {
        
        // TODO: just hardcoding in UserDefaults - in future could query API Configuration first
        storage.setValue("https://image.tmdb.org/t/p/w185", forKey: UserDefaultsKey.photoRootPath.rawValue)
    }
}

extension Model {
    
    private static var keyWatchersArray: String {
        return UserDefaultsKey.watchersArray.rawValue
    }
    
    private static var defaultWatcherPrefix: String {
        return "Watcher"
    }
    
    private static var defaultWatchers: [Watcher] {
        return ["\(Model.defaultWatcherPrefix) 1", "\(Model.defaultWatcherPrefix) 2"]
    }

    public var watchers: [Watcher] {
        get {
            guard let watchers = storage.array(forKey: Model.keyWatchersArray) as? [Watcher] else {
                return Model.defaultWatchers
            }
            
            return watchers
        }
        
        set {
            storage.set(newValue, forKey: Model.keyWatchersArray)
        }
    }
    
    public var watcherCount: Int {
        return watchers.count
    }
}

extension Model {
    
    public func getGenres(completion: @escaping ([Genre]) -> Void) {
        
        // genres are driven by the API, so we send a fetch request
        let endpoint = TMBDEndpoint.genres
        client.fetch(endpoint: endpoint, parse: endpoint.parser) { result in

            switch result {
                
            case .failure(let error):
                print("Network error: \(error)")
                completion([])
                
            case .success(let payload):
                if let concreteResults = payload as? [Genre] {
                    completion(concreteResults)
                } else {
                    print("Conversion error: couldn't convert payload to Genres")
                    completion([])
                }
            }
        }
    }
    
    public func getPeople(completion: @escaping ([Person]) -> Void) {
        
        for page in 1...10 {

            let endpoint = TMBDEndpoint.popularPeople(page)
            client.fetch(endpoint: endpoint, parse: endpoint.parser) { result in

                switch result {
                case .failure(let error):
                    print(error)
                case .success(let payload):
                    if let concreteResults = payload as? [Person] {

                        completion(concreteResults) // may get called multiple times
                    }
                }
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
            
            NotificationCenter.default.post(name: NSNotification.Name("Error"), object: nil, userInfo: ["Message" : message])
        }
    }

}

extension Model {
    
    private var allSelections: [WatcherSelection] {
        return watcherSelections
    }
    
    public func goToNextSelectionStep() {
        
        // check to see if we would go beyond the last watcher
        if currentWatcherIndex == allSelections.count - 1 {
            
            // check to see what mode we are in
            if selectionMode == .preferencesSelection {
                
                // move to the next mode
                selectionMode = .movieSelection
                currentWatcherIndex = 0
                
            } else {
                
                // we are done!
                selectionMode = .done
            }
            
        } else {
            
            // increment to the next watcher
            currentWatcherIndex += 1
        }
    }
    
    public func goBackToPreviousSelectionStep() {
        
        if selectionMode == .done {
            
            currentWatcherIndex = allSelections.count-1
            selectionMode = .movieSelection
            
        } else {
            
            currentWatcherIndex -= 1
            
            if currentWatcherIndex < 0 {
                
                if selectionMode == .movieSelection {
                    
                    currentWatcherIndex = allSelections.count-1
                    selectionMode = .preferencesSelection
                    movieResults = []
                    
                    // clear out any old movie selections
                    for selection in allSelections {
                        selection.selectedResults = []
                    }
                    
                } else {
                
                    currentWatcherIndex = 0
                }
            }
        }
    }
    
    public func goToFirstSelectionStep() {
        
        var emptyWatcherSelections: [WatcherSelection] = []
        
        for _ in watchers {
            emptyWatcherSelections.append(WatcherSelection())
        }
        
        watcherSelections = emptyWatcherSelections
        
        currentWatcherIndex = 0
        selectionMode = .preferencesSelection
        movieResults = []
    }
}

protocol DataDelegate: class { }

extension Model: PassDeviceDataDelegate { }

extension Model: SetUpDataDelegate {
    
    public func addDefaultWatcher() {
        watchers += ["\(Model.defaultWatcherPrefix) \(watchers.count + 1)"]
    }
    
    public func removeWatcher(atIndex index: Int) {
        
        if watchers.indices.contains(index) {
            watchers.remove(at: index)
        }
    }
}

extension Model: EditWatcherDataDelegate {
    
    public var currentUserName: String {
        get {
            if watchers.indices.contains(currentWatcherIndex) {
                return watchers[currentWatcherIndex]
            } else {
                return "<unknown>"
            }
        }
        
        set {
            if watchers.indices.contains(currentWatcherIndex) {
                watchers[currentWatcherIndex] = newValue
            }
        }
    }
}

extension Model: PreferenceTypeListDataDelegate {
    
    func setCurrentPreferenceType(preferenceType: PreferenceType) {
        currentPreferenceType = preferenceType
    }
    
    var currentUserHasMadeSelections: Bool {
        return currentWatcherSelection.description != ""
    }
    
    var currentWatcherSelection: WatcherSelection {
        return watcherSelections[currentWatcherIndex]
    }
}

extension Model: ProcessingDataDelegate {
    
    public func assignMeAsProcessingCompletedDelegate(delegate: ProcessingCompletedDelegate) {
        processingCompletedDelegate = delegate
    }
    
    public func processSelections() {
        
        // Clear previous movies
        movieResults.removeAll()
        
        for selection in allSelections {
            
            let eras = selection.selectedEras
            let genreIds = selection.selectedGenres.map { $0.id }
            let personIds = selection.selectedPeople.map { $0.id }
            
            if eras.count > 0 {
                
                // process criteria in the context of one era at a time

                for era in selection.selectedEras {

                    processForEra(era: era, genreIds: genreIds, personIds: personIds)
                }
                
            } else {

                // no eras set - so just process with nil era
                processForEra(era: nil, genreIds: genreIds, personIds: personIds)
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("Dispatch group ran now!")
            self.processingCompletedDelegate?.onProcessingCompleted()
        }

    }
    
    // this method encapsualtes the basic algorithm
    //   - send multiple requests
    //   - prioritize results that match ALL criteria (for a given era)
    //   - then make requests that hit on components of the overall criteria
    private func processForEra(era: MovieEra?, genreIds: [Int], personIds: [Int]) {

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
    private func process(type: DiscoverType, priority: ResultPriority) {

        let endpoint = TMBDEndpoint.discover(type)

        dispatchGroup.enter()
        
        client.fetch(endpoint: endpoint, parse: endpoint.parser) { [weak self] result in

            if let strongSelf = self {

                strongSelf.handleResult(priority: priority, result: result)
                strongSelf.dispatchGroup.leave()
            }
        }
    }

    // handle results of any incoming results
    func handleResult(priority: ResultPriority, result: APIResult<[JSONInitable]>) {

        switch result {
            
        case .success(let payload):

            if let newMovies = payload as? [Movie] {

                if movieResults.isEmpty {
                    
                    // First (possibly only) query to return, so just add the new results

                    // turn the incoming movies in to prioritized results
                    let newPrioritizableResults = newMovies.map { PrioritizableResult(priority: priority, movie: $0) }

                    movieResults = newPrioritizableResults
                    
                } else {
                    
                    // Other queries have returned before this one, so we need to do the deduping process
                    
                    var dedupingDictionary: [ Movie : ResultPriority ] = [:]
                    
                    // Add existing entries to the deduping dictionary
                    for prioritizableResult in movieResults {
                        dedupingDictionary[prioritizableResult.movie] = prioritizableResult.priority
                    }
                    
                    // Conditionally add the new entries based on priority
                    for movie in newMovies {
                        
                        if let existingPriority = dedupingDictionary[movie] {
                            
                            // Movie already exists, if our priority is higher, then replace
                            if priority.rawValue > existingPriority.rawValue {
                                dedupingDictionary[movie] = priority
                            }
                            
                        } else {
                            
                            // Movie doesn't exist yet, so just add it
                            dedupingDictionary[movie] = priority
                        }
                    }
                    
                    // Now turn the dictionary back into PrioritizableResults
                    var newPrioritizableResults: [PrioritizableResult] = []
                    
                    for movie in Array(dedupingDictionary.keys) {
                        
                        if let priority = dedupingDictionary[movie] {

                            let newPrioritizableResult = PrioritizableResult(priority: priority, movie: movie)
                            newPrioritizableResults.append(newPrioritizableResult)
                        }
                    }
                    

                    movieResults = newPrioritizableResults
                }
                
                movieResults.sort { (first, second) -> Bool in
                    
                    if first.priority.rawValue != second.priority.rawValue {

                        return first.priority.rawValue > second.priority.rawValue

                    } else {

                        return first.movie.voteAverage > second.movie.voteAverage

                    }
                }
            }

        case .failure(let error):
            // TODO: handle error
            print("Request error: \(error)")
            break
        }
    }
}

extension Model: MovieListDataDelegate {
    
    public func applyMovieSelectionsForCurrentWatcher(moviePicks: [PrioritizableResult]) {
        
        currentWatcherSelection.selectedResults = moviePicks
    }
}
extension Model: ResultsDataDelegate {
    
    var allSelectedMovies: [Movie] {
        
        let allPrioritizableResults = allSelections.flatMap { $0.selectedResults }
        let allMovies = allPrioritizableResults.compactMap { $0.movie }
        return allMovies
    }
}
