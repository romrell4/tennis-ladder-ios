//
//  Match.swift
//  TennisLadder
//
//  Created by Eric Romrell on 12/20/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation

struct Match: Codable {
	let matchId: Int?
	let ladderId: Int
	let matchDate: Date?
	let winner: Player
	let loser: Player
	var winnerSet1Score: Int
	var loserSet1Score: Int
	var winnerSet2Score: Int
	var loserSet2Score: Int
	var winnerSet3Score: Int?
	var loserSet3Score: Int?
}
