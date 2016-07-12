//
//  OTMDetailNameTableViewCell.swift
//  OnTheMap
//
//  Created by Jun.Yuan on 16/7/11.
//  Copyright © 2016年 Jun.Yuan. All rights reserved.
//

import UIKit

class OTMDetailNameTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    override func drawRect(rect: CGRect) {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2.0
        avatarImageView.layer.masksToBounds = true
    }
}
