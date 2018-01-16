//
//  UserObjectViewCell.swift
//  BeaverRuler
//
//  Created by Aleksandr Khotyashov on 8/23/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import UIKit

class UserObjectViewCell: UITableViewCell {

    @IBOutlet weak var objectName: UILabel!
    @IBOutlet weak var objectSize: UILabel!
    @IBOutlet weak var dateCreated: UILabel!
    
    var objectIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
