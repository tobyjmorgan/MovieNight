//
//  PhotoListCell.swift
//  MovieNight
//
//  Created by redBred LLC on 12/15/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit
import SAMCache

class PhotoListCell: UICollectionViewCell {
 
    @IBOutlet var cellContainer: UIView!
    @IBOutlet var imageViewContainer: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    var photoURL: String? = nil {
        didSet {
            if let cachedImage = SAMCache.shared().image(forKey: photoURL) {
                
                imageView.image = cachedImage
                
            } else {
                
                UIImage.getImageAsynchronously(urlString: photoURL) { image in
                    
                    self.imageView.image = image
                }
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                animateToSelected()
            } else {
                animateToUnselected()
            }
        }
    }
    
    func animateToSelected() {
        UIView.animate(withDuration: 0.25, animations: { self.cellContainer.backgroundColor = UIColor.myBlue })
    }

    func animateToUnselected() {
        UIView.animate(withDuration: 0.25, animations: { self.cellContainer.backgroundColor = UIColor.clear })
    }
}
