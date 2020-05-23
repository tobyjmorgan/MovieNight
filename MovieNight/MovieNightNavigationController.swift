//
//  MovieNightNavigationController.swift
//  MovieNight
//
//  Created by redBred LLC on 5/20/20.
//  Copyright © 2020 redBred. All rights reserved.
//

import UIKit

class MovieNightNavigationController: UINavigationController {

    let model = Model()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleError(userInfo:)), name: NSNotification.Name(rawValue: "Error"), object: nil)

        // Do any additional setup after loading the view.
        push_SetUp()
    }
    
    @objc func handleError(userInfo: [String : Any]) {
        
        if let message = userInfo["Message"] as? String {
            
            let alert = UIAlertController(title: "Ouch!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


// MARK: - Navigation

extension MovieNightNavigationController {
    
    private func push_SetUp() {
        
        if let vc = Screen.setUp.instantiate as? SetUpViewController {
            
            vc.dataDelegate = model
            vc.navDelegate = self
            pushViewController(vc, animated: false)
        }
    }
    
    private func push_EditWatcher() {
        
        if let vc = Screen.editWatcher.instantiate as? EditWatcherViewController {
            
            vc.dataDelegate = model
            pushViewController(vc, animated: true)
        }
    }
    
    private func push_PassDevice() {
        
        if let vc = Screen.passDevice.instantiate as? PassDeviceViewController {
            
            vc.dataDelegate = model
            vc.navDelegate = self
            vc.navigationItem.title = model.currentUserName
            pushViewController(vc, animated: true)
        }
    }
    
    private func push_PreferenceType() {
        
        if let vc = Screen.preferenceType.instantiate as? PreferenceTypeListViewController {
            
            vc.dataDelegate = model
            vc.navDelegate = self
            pushViewController(vc, animated: true)
        }
    }
    
    private func push_Processing() {
        
        if let vc = Screen.processing.instantiate as? ProcessingViewController {
            
            vc.dataDelegate = model
            vc.navDelegate = self
            pushViewController(vc, animated: true)
        }
    }
    
    private func push_MovieList() {
        
        if let vc = Screen.movieList.instantiate as? MovieListViewController {
            
            vc.dataDelegate = model
            vc.navDelegate = self
            pushViewController(vc, animated: true)
        }
    }
    
    private func push_MovieDetails(movie: Movie) {
        
        if let vc = Screen.movieDetail.instantiate as? MovieDetailViewController {
            
            vc.movie = movie
            pushViewController(vc, animated: true)
        }
    }

    private func push_Results() {
        
        if let vc = Screen.results.instantiate as? ResultsViewController {
            
            vc.dataDelegate = model
            vc.navDelegate = self
            pushViewController(vc, animated: true)
        }
    }
    
    private func push_GenericListForEras() {
        
        if let vc = Screen.genericList.instantiate as? ListViewController {
            
            // eras use hardcoded data, so no API request needed
            vc.list = MovieEra.allValues
            vc.navigationItem.title = "Movie Eras"
            vc.instruction = "Pick any movie eras you prefer..."
            vc.initiallyPicked = model.currentWatcherSelection.selectedEras

            vc.dismissCompletion = {[weak self] listables in
            
                if let eras = listables as? [MovieEra] {
            
                    self?.model.currentWatcherSelection.selectedEras = eras
                }
            }
            
            pushViewController(vc, animated: true)
        }
    }
    
    private func push_GenericListForGenres() {
        
        if let vc = Screen.genericList.instantiate as? ListViewController {
            
            vc.navigationItem.title = "Genres"
            vc.instruction = "Pick some genres..."
            vc.initiallyPicked = model.currentWatcherSelection.selectedGenres

            model.getGenres { (results) in
                vc.list = results
            }
            
            vc.dismissCompletion = {[weak self] listables in

                if let genres = listables as? [Genre] {

                    self?.model.currentWatcherSelection.selectedGenres = genres
                }
            }

            pushViewController(vc, animated: true)
        }

    }
    
    private func push_GenericPhotoListForPeople() {
        
        if let vc = Screen.genericPhotoList.instantiate as? PhotoListViewController {
            
            vc.navigationItem.title = "Stars"
            vc.instruction = "Pick your favorite stars..."

            model.getPeople { (results) in
                vc.list.append(contentsOf: results)
            }

            vc.dismissCompletion = {[weak self] listables in

                if let people = listables as? [Person] {

                    self?.model.currentWatcherSelection.selectedPeople = people
                }
            }

            pushViewController(vc, animated: true)
        }
    }
}


// MARK: - Navigation Delegates

protocol NavDelegate: class { }

extension MovieNightNavigationController: SetUpNavDelegate {
    
    public func onNavStartSearch() {

        if model.watchers.count < 2 {

            push_PreferenceType()

        } else {

            push_PassDevice()
        }
    }
    
    public func onNavEditWatcher(watcherIndex: Int) {
        
        model.currentWatcherIndex = watcherIndex
        
        push_EditWatcher()
    }
}

extension MovieNightNavigationController: PassDeviceNavDelegate {
    
    public func onNextStepPassDevice() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
        
        switch model.selectionMode {

            case .preferencesSelection:
                
                push_PreferenceType()
            
            case .movieSelection:
                
                push_MovieList()
            
            default:
                // should never get here
                break
        }
    }
}

extension MovieNightNavigationController: PreferenceTypeListNavDelegate {
    
    public func onShowPreferenceTypeDetails() {
        
        print("Show \(model.currentPreferenceType.description)")

        switch model.currentPreferenceType {
        
        case .genres:
            push_GenericListForGenres()
            
        case .eras:
            push_GenericListForEras()
            
        case .people:
            push_GenericPhotoListForPeople()
        }
    }
    
    public func onNextStepPreferenceTypeList() {

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
            
            if model.selectionMode == .movieSelection {
                
                push_Processing()
                
            } else {
                
                push_PassDevice()
            }
    }
}

extension MovieNightNavigationController: ProcessingNavDelegate {
    
    public func onNextStepProcessing() {
        
        if model.watcherCount < 2 {
            
            push_MovieList()

        } else {

            push_PassDevice()
        }
    }

}

extension MovieNightNavigationController: MovieListNavDelegate{
    
    public func onViewMovieDetails(movie: Movie) {
        
        push_MovieDetails(movie: movie)
    }
    
    public func onNextStepMovieList() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
        
        if model.selectionMode == .done {
            
            push_Results()
            
        } else {
            
            if model.watcherCount > 1 {

                push_PassDevice()

            } else {
                push_Results()
            }
        }

    }
}

extension MovieNightNavigationController: ResultsNavDelegate {
    
    public func onStartOver() {
        popToRootViewController(animated: true)
    }
}
