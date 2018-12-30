//
//  DetailCell.swift
//  TennisLadder
//
//  Created by Z Tai on 12/21/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    @IBOutlet private weak var matchLabel: UILabel!
    @IBOutlet private weak var setLabel: UILabel!
    
    var match: Match! {
        didSet {
            matchLabel.text = "Match \(match.matchId)"
            setLabel.text = match.scoreDisplay
        }
    }
}
