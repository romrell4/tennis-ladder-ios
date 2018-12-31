//
//  PlayerTableViewCell.swift
//  TennisLadder
//
//  Created by Z Tai on 12/12/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var points: UILabel!
    @IBOutlet private weak var userImage: UIImageView!

    var player: Player! {
        didSet {
            name.text = player.name
            points.text = String(player.score)
            userImage.moa.url = player.photoUrl
        }
    }
}
