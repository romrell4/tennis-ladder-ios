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
    //TODO: Change back to a Date
	let matchDate: String?
	let winner: Player
	let loser: Player
	var winnerSet1Score: Int
	var loserSet1Score: Int
	var winnerSet2Score: Int
	var loserSet2Score: Int
	var winnerSet3Score: Int?
	var loserSet3Score: Int?
    
    var scoreDisplay: String {
        let sets = [
            (winnerSet1Score, loserSet1Score),
            (winnerSet2Score, loserSet2Score),
            (winnerSet3Score, loserSet3Score)
        ]
        
        return sets.filter { $0.0 != nil && $0.1 != nil }
            .map { "\($0.0 ?? 0)-\($0.1 ?? 0)" }
            .joined(separator: ", ")
    }
}
