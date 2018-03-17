//
//  NativeAppInstallAdCell.swift
//  BeaverRuler
//
//  Created by Aleksandr Khotyashov on 9/5/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import UIKit
import Appodeal

class NativeAppInstallAdCell: UITableViewCell {

    @IBOutlet weak var mediaView: APDMediaView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var callToActionLabel: UILabel!
    @IBOutlet weak var adBadgeLabel: UILabel!

    var nativeAd : APDNativeAd!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        adBadgeLabel.backgroundColor = UIColor.darkGray
        adBadgeLabel.text = "Ad"
        adBadgeLabel.textColor = UIColor.white
        adBadgeLabel.textAlignment = NSTextAlignment.center
        adBadgeLabel.font = UIFont.systemFont(ofSize: 10)
        adBadgeLabel.layer.cornerRadius = 2.0

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.darkGray
        titleLabel.text = ""

        callToActionLabel.textColor = UIColor.darkGray
        callToActionLabel.textAlignment = NSTextAlignment.center
        callToActionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        callToActionLabel.layer.cornerRadius = 5.0
        callToActionLabel.layer.borderWidth = 2.0
        callToActionLabel.layer.borderColor = UIColor.darkGray.cgColor
        callToActionLabel.text = ""

        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textAlignment = NSTextAlignment.left
        descriptionLabel.textColor = UIColor.gray
        descriptionLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
