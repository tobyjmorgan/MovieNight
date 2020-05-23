//
//  MovieCell.swift
//  MovieNight
//
//  Created by redBred LLC on 12/16/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit
import SAMCache

class MovieCell: UITableViewCell {

    @IBOutlet var moviePhoto: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var cellFrame: UIView!
    
    var photoURL: String? = nil {
        didSet {
            
            if let cachedImage = SAMCache.shared().image(forKey: photoURL) {
                
                moviePhoto.image = cachedImage
                
            } else {
                
                UIImage.getImageAsynchronously(urlString: photoURL) { image in
                    
                    self.moviePhoto.image = image
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        moviePhoto.layer.cornerRadius = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
