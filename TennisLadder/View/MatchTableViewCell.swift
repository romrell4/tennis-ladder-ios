//
//  MatchTableViewCell.swift
//  TennisLadder
//
//  Created by Eric Romrell on 1/14/19.
//  Copyright © 2019 Z Tai. All rights reserved.
//

import UIKit

private let DATE_FORMATTER = DateFormatter.defaultDateFormat("M/d/yyyy")

class MatchTableViewCell: UITableViewCell {
	//MARK: Outlets
	@IBOutlet private weak var nameLabel: UILabel!
	@IBOutlet private weak var dateLabel: UILabel!
	@IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var earnedPointsLabel: UILabel!
    
	//MARK: Public Functions
	func setup(match: Match, for player: Player) {
		nameLabel.text = [match.winner, match.loser].first { $0 != player }?.user.name
		dateLabel.text = DATE_FORMATTER.string(fromOptional: match.matchDate)
		scoreLabel.text = match.scoreDisplay(forPlayer: player)
        earnedPointsLabel.text = "Earned points: \(match.points(forPlayer: player))"
        let color: UIColor = (match.winner == player) ? .matchWinner : .matchLoser
		scoreLabel.textColor = color
        earnedPointsLabel.textColor = color
	}
}
