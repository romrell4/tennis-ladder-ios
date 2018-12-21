//
//  Match.swift
//  TennisLadder
//
//  Created by Eric Romrell on 12/20/18.
//  Copyright © 2018 Z Tai. All rights reserved.
//

import Foundation

struct Match: Codable {
	let matchId: Int
	let ladderId: Int
	let matchDate: Date
	let winner: Player
	let loser: Player
	let winnerSet1Score: Int
	let loserSet1Score: Int
	let winnerSet2Score: Int
	let loserSet2Score: Int
	let winnerSet3Score: Int?
	let loserSet3Score: Int?
}
