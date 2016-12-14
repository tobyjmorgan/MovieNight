//
//  PeopleCollectionViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/14/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PersonCell"

class PeopleCollectionViewController: UICollectionViewController {

    let client = TMBDAPIClient()
    let maxCount = 5

    var userSelectionDelegate: UserSelectionDelegate?

    @IBOutlet var pickCountLabel: UILabel!
    
    var people: [Person] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let endpoint = TMBDEndpoint.popularPeople
        client.fetch(endpoint: endpoint, parse: endpoint.parser) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let payload):
                if let concreteResults = payload as? [Person] {
                    self.people = concreteResults
                }
            }
        }

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updatePickCountLabel() {
        
        var count = 0
        
        if let selectedItems = collectionView?.indexPathsForSelectedItems {
            count = selectedItems.count
        }
        
        pickCountLabel.text = "You have picked \(count)/\(maxCount)"
    }
    
    
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        // clear out any residual stuff from cell's former life
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // get the appropriate person information based on index path
        if people.indices.contains(indexPath.item) {
            
            let person = people[indexPath.item]
            
            if person.profilePath != "" {
                
                // get the image for this person
                if let url = URL(string: "https://image.tmdb.org/t/p/w185\(person.profilePath)") {
                    
                    do {
                        let data = try Data(contentsOf: url)
                        
                        let image = UIImage(data: data)
                        let imageView = UIImageView(image: image)
                        imageView.contentMode = .scaleAspectFit
                        imageView.frame = cell.contentView.bounds
                        cell.contentView.addSubview(imageView)

                    } catch {

                        let nameLabel = UILabel(frame: cell.contentView.bounds)
                        nameLabel.text = person.name

                    }
                }
                
            } else {
                
                let nameLabel = UILabel(frame: cell.contentView.bounds)
                nameLabel.text = person.name
            }
            
        }
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems,
            let firstIndexPath = selectedIndexPaths.first {
            
            if selectedIndexPaths.count > maxCount {
                collectionView.deselectItem(at: firstIndexPath, animated: true)
            }
        }
        
        updatePickCountLabel()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updatePickCountLabel()
    }

    
    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
