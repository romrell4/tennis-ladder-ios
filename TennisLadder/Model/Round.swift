//
//  Round.swift
//  TennisLadder
//
//  Created by Eric Romrell on 7/15/20.
//  Copyright © 2020 Z Tai. All rights reserved.
//

import Foundation

struct Round: Codable {
	let roundId: Int
	let dates: String
	let matches: [TournamentMatch]
}
