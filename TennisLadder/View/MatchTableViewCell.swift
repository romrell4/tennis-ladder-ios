//
//  DetailCell.swift
//  TennisLadder
//
//  Created by Z Tai on 12/21/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    var match: Match! {
        didSet {
            textLabel?.text = "Player \(match.matchId)"
            detailTextLabel?.text = match.scoreDisplay
        }
    }
}
