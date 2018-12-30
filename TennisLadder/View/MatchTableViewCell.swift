//
//  DetailCell.swift
//  TennisLadder
//
//  Created by Z Tai on 12/21/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    @IBOutlet private weak var opponentNameLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!
    
    var match: Match! {
        didSet {
            opponentNameLabel.text = "Player \(match.matchId)"
            scoreLabel.text = match.scoreDisplay
        }
    }
}
