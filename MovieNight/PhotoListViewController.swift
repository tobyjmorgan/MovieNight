//
//  PhotoListViewController.swift
//  MovieNight
//
//  Created by redBred LLC on 12/15/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class PhotoListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var maxPickCount: Int = 3
    var instruction: String = "Please make your selections..."
    var dismissCompletion: (([PhotoListable]) -> ())? = nil
    @IBOutlet var footerView: UIView!
    
    var initiallyPicked: [Listable] = []
    
    // generic table view, so we don't care what underlying type is passed, as long
    // as it conforms to PhotoListable
    var list: [PhotoListable] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var pickCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsMultipleSelection = true
        
        instructionLabel.text = instruction
        updatePickCountLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveSelections()
    }
    
    func updatePickCountLabel() {
        
        var count = 0
        
        if let selected = collectionView.indexPathsForSelectedItems {
            count = selected.count
        }
        
        pickCountLabel.text = "You have picked \(initiallyPicked.count + count)/\(maxPickCount)"
    }
    
    func saveSelections() {
        
        var returnList: [PhotoListable] = []
        
        if let selected = collectionView.indexPathsForSelectedItems {
            
            returnList = selected.map { list[$0.item] }
        }
        
        dismissCompletion?(returnList)
    }

    func maximumSelected() {
        
        // play sound
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayAlertSound.rawValue), object: nil)
        
        // flash the footer
        UIView.animate(withDuration: 0.25, animations: {self.footerView.backgroundColor = UIColor.myBlue}) { bool in
            UIView.animate(withDuration: 0.25, animations: {self.footerView.backgroundColor = UIColor.myFaintWhite})
        }
    }
    
    
    
    ///////////////////////////////////////////////
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoListCell
        
        // clear out any residual stuff from cell's former life
        cell.nameLabel?.text = ""
        
        // check for out of bounds
        if list.indices.contains(indexPath.row) {
            
            // fetch the corresponding list item for the row
            let item = list[indexPath.item]
            
            // set the cell values
            cell.nameLabel?.text = item.titleForItem
            cell.photoURL = item.photoURL
            
            // pretty things up a bit
            cell.cellContainer.layer.cornerRadius = 10.0
            cell.cellContainer.layer.borderColor = UIColor.white.cgColor
            cell.cellContainer.layer.borderWidth = 2.0
            
            // set up previously picked items based on initiallyPicked array
            if let index = initiallyPicked.index(where: { $0.uniqueID == item.uniqueID}) {
                
                // TODO: known bug - selections not consistently remembered when returning to this screen
                // mark cell as selected
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                cell.isSelected = true
                //cell.animateToSelected()
                
                // remove the item from the initially picked list
                // since we are done with initially setting this item up
                initiallyPicked.remove(at: index)

                updatePickCountLabel()
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            
            if (initiallyPicked.count + selectedIndexPaths.count) >= maxPickCount {
                maximumSelected()
                return false
            }
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SoundManager.Notifications.notificationPlayClickSound.rawValue), object: nil)
        updatePickCountLabel()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updatePickCountLabel()
    }

}
