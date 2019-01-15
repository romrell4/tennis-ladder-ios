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
    
	func scoreDisplay(forPlayer player: Player) -> String {
        let sets = [
            (winnerSet1Score, loserSet1Score),
            (winnerSet2Score, loserSet2Score),
            (winnerSet3Score, loserSet3Score)
        ]
		
		return sets.filter { $0.0 != nil && $0.1 != nil }
			.map { player == winner ? "\($0.0!)-\($0.1!)" : "\($0.1!)-\($0.0!)" }
			.joined(separator: ", ")
    }
}
