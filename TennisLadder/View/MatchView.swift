//
//  MatchView.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

let MATCH_CELL_HEIGHT: CGFloat = 44

class TournamentMatchView: UIView, UITableViewDataSource, UITableViewDelegate {
	//MARK: Outlets
	@IBOutlet private weak var tableView: UITableView!
	
	//MARK: Public properties
	var match: TournamentMatch! {
		didSet {
			tableView.reloadData()
		}
	}
	
	static func initWith(match: TournamentMatch) -> TournamentMatchView {
		let matchView = UINib(nibName: "MatchView", bundle: nil).instantiate(withOwner: self, options: nil).first as! TournamentMatchView
		matchView.match = match
		return matchView
	}
	
	override func awakeFromNib() {
		tableView.isScrollEnabled = false
//		tableView.layer.borderColor = UIColor.bcGreen.cgColor
		tableView.layer.borderWidth = 1
		tableView.layer.cornerRadius = 8
		tableView.delegate = self
		tableView.dataSource = self
		tableView.registerNib(nibName: "MatchTableViewCell")
	}
	
	//UITableViewDataSource/Delegate callbacks
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return MATCH_CELL_HEIGHT
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueCell(at: indexPath) as? TournamentMatchTableViewCell {
			if indexPath.row == 0 {
				cell.nameLabel.text = match?.player1Full
			} else {
				cell.nameLabel.text = match?.player2Full
			}
			return cell
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//TODO: Go to the match reporting screen if the user is allowed
	}
}
