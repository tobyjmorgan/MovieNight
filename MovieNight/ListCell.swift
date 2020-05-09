//
//  ListCell.swift
//  MovieNight
//
//  Created by redBred LLC on 12/15/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            
            accessoryType = UITableViewCell.AccessoryType.checkmark
            
        } else {
            
            accessoryType = UITableViewCell.AccessoryType.none
        }
    }

}
