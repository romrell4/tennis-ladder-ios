//
//  TournamentMatch.swift
//  TennisLadder
//
//  Created by Eric Romrell on 7/15/20.
//  Copyright © 2020 Z Tai. All rights reserved.
//

import Foundation

struct TournamentMatch: Codable {
	let player1: Player
	let player2: Player
	let match: Match
	
	let player1Full: String
	let player2Full: String
}
