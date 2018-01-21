//
//  CelebrityViewCell.swift
//  GHeight
//
//  Created by user on 1/22/18.
//  Copyright © 2018 user. All rights reserved.
//

import UIKit

class CelebrityViewCell: UITableViewCell {

    @IBOutlet weak var celebrityName: UILabel!
    @IBOutlet weak var celebrityHeight: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
