//
//  MatchView.swift
//  BracketChallenge
//
//  Created by Eric Romrell on 7/15/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

let MATCH_CELL_HEIGHT: CGFloat = 44

protocol MatchViewClickableDelegate {
	func areCellsClickable() -> Bool
}

protocol MatchViewDelegate {
	func player(_ player: Player?, selectedInView view: MatchView)
}

class MatchView: UIView, UITableViewDataSource, UITableViewDelegate {
	//MARK: Outlets
	@IBOutlet private weak var tableView: UITableView!
	
	//MARK: Public properties
	var match: MatchHelper! {
		didSet {
			tableView.reloadData()
		}
	}
	var masterMatch: MatchHelper? {
		didSet {
			tableView.reloadData()
		}
	}
	
	//MARK: Private properties
	private var delegate: MatchViewDelegate!
	private var clickDelegate: MatchViewClickableDelegate!
	
	static func initWith(delegate: MatchViewDelegate, clickDelegate: MatchViewClickableDelegate, match: MatchHelper, masterMatch: MatchHelper?) -> MatchView {
		let matchView = UINib(nibName: "MatchView", bundle: nil).instantiate(withOwner: self, options: nil).first as! MatchView
		matchView.delegate = delegate
		matchView.clickDelegate = clickDelegate
		matchView.match = match
		matchView.masterMatch = masterMatch
		return matchView
	}
	
	override func awakeFromNib() {
		tableView.isScrollEnabled = false
		tableView.layer.borderColor = UIColor.bcGreen.cgColor
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
		if let cell = tableView.dequeueReusableCell(for: indexPath) as? MatchTableViewCell {
			if indexPath.row == 0 {
				cell.nameLabel.text = match?.player1Full
				cell.checked = match?.winnerId != nil && match?.winnerId == match?.player1Id
				cell.isUserInteractionEnabled = match?.player1 != nil
				cell.nameLabel.textColor = textColorFor(playerId: match?.player1Id, predictionId: match?.winnerId, winnerId: masterMatch?.winnerId)
			} else {
				cell.nameLabel.text = match?.player2Full
				cell.checked = match?.winner != nil && match?.winnerId == match?.player2Id
				cell.isUserInteractionEnabled = match?.player2 != nil
				cell.nameLabel.textColor = textColorFor(playerId: match?.player2Id, predictionId: match?.winnerId, winnerId: masterMatch?.winnerId)
			}
			return cell
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if clickDelegate.areCellsClickable() {
			let otherIndexPath = IndexPath(row: indexPath.row == 0 ? 1 : 0, section: indexPath.section)
			if let cell = tableView.cellForRow(at: indexPath) as? MatchTableViewCell, let otherCell = tableView.cellForRow(at: otherIndexPath) as? MatchTableViewCell {
				if cell.checked {
					cell.checked = false
					delegate?.player(nil, selectedInView: self)
				} else {
					//When selecting a cell, the other one should deselect
					cell.checked = true
					otherCell.checked = false
					
					//Notify the CollectionViewCell that a cell was selected
					let player = indexPath.row == 0 ? match?.player1 : match?.player2
					delegate?.player(player, selectedInView: self)
				}
			}
		}
	}
	
	//Private functions
	
	func textColorFor(playerId: Int?, predictionId: Int?, winnerId: Int?) -> UIColor {
		if playerId == nil || winnerId == nil || predictionId == nil {
			//The match isn't finished, or the user hasn't selected a winner yet
			return .black
		} else if predictionId == playerId {
			//We predicted this player. If they won, green. If they lost, red.
			return winnerId == playerId ? .winnerGreen : .red
		} else {
			//We didn't predict this player. If they won, black. If they lost, gray
			return winnerId == playerId ? .black : .lightGray
		}
	}
}
