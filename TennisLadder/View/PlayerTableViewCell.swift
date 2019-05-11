//
//  PlayerTableViewCell.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
	@IBOutlet private weak var userImage: UIImageView!
    @IBOutlet private weak var name: UILabel!
	@IBOutlet private weak var earnedPointsLabel: UILabel!
	@IBOutlet private weak var borrowedPointsLabel: UILabel!
	@IBOutlet private weak var points: UILabel!

    var player: Player! {
        didSet {
            name.text = player.user.name
			earnedPointsLabel.text = "Earned: \(player.earnedPoints)"
			borrowedPointsLabel.text = "Borrowed: \(player.borrowedPoints)"
			points.text = "Total: \(player.score)"
			userImage.image = UIImage(named: "userIcon")
			if let photoUrl = player.user.photoUrl {
				userImage.moa.url = photoUrl
			}
        }
    }
}
